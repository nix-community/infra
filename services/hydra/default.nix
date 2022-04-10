{ hydra }:
{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config;

  hydraPort = 3000;
  hydraAdmin = "admin";
  hydraAdminPasswordFile = config.sops.secrets.hydra-admin-password.path;
  hydraUsersFile = config.sops.secrets.hydra-users.path;

  createDeclarativeProjectScript = pkgs.stdenv.mkDerivation {
    name = "create-declarative-project";
    unpackPhase = ":";
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = "install -m755 -D ${./create-declarative-project.sh} $out/bin/create-declarative-project";
    postFixup = ''
      wrapProgram "$out/bin/create-declarative-project" \
        --prefix PATH ":" ${lib.makeBinPath [ pkgs.curl ]}
    '';
  };

in
{
  imports = [ ./declarative-projects.nix ];

  options.services.hydra = {
    adminPasswordFile = mkOption {
      type = types.str;
      description = "The initial password for the Hydra admin account";
    };

    usersFile = mkOption {
      type = types.str;
      description = ''
        declarative user accounts for hydra.
        format: user;role;password-hash;email-address;full-name
        Password hash is computed by applying sha1 to the password.
      '';
    };

    declarativeProjects = mkOption {
      description = "Declarative projects";
      default = { };
      type = with types; attrsOf (submodule {
        options = {
          inputValue = mkOption {
            type = types.str;
            description = "The input value";
            example = "https://github.com/shlevy/declarative-hydra-example";
          };
          inputType = mkOption {
            type = types.str;
            default = "git";
            description = "The type of the input value";
          };
          specFile = mkOption {
            type = types.str;
            default = "spec.json";
            description = "The declarative spec file name";
          };
          displayName = mkOption {
            type = types.str;
            description = "The diplay name of the declarative project";
          };
          description = mkOption {
            type = types.str;
            default = "";
            description = "The description of the declarative project";
          };
          homepage = mkOption {
            type = types.str;
            default = "";
            description = "The homepage of the declarative project";
          };
        };
      });
    };
  };
  config = {
    sops.secrets.hydra-admin-password.owner = "hydra";
    sops.secrets.hydra-users.owner = "hydra";

    nixpkgs.config = {
      whitelistedLicenses = with lib.licenses; [
        unfreeRedistributable
        issl
      ];
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "cudnn_cudatoolkit"
        "cudatoolkit"
      ];
    };

    services.hydra.package = hydra.defaultPackage.${pkgs.system};

    sops.secrets.nix-community-cachix = {
      owner = "hydra-queue-runner";
      sopsFile = ../../roles/nix-community-cache.yaml;
    };

    services.hydra = {
      enable = true;
      hydraURL = "https://hydra.nix-community.org";
      notificationSender = "hydra@hydra.nix-community.org";
      port = hydraPort;
      useSubstitutes = true;
      adminPasswordFile = hydraAdminPasswordFile;

      usersFile = hydraUsersFile;
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}

        <runcommand>
        command = ${pkgs.writeShellScript "cachix-upload" ''
          export PATH=${config.nix.package}/bin
          ${pkgs.jq}/bin/jq -r '.outputs | .[] | .path' < $HYDRA_JSON | \
            ${pkgs.cachix}/bin/cachix -c ${config.sops.secrets.nix-community-cachix.path} push nix-community
        ''}
        </runcommand>
      '';
    };

    services.postgresql = {
      enable = true;
      settings = {
        effective_cache_size = "4GB";
        shared_buffers = "4GB";
      };
    };

    nix = {
      distributedBuilds = true;
      # needed to fix https://github.com/NixOS/nix/issues/5980
      package = pkgs.nixUnstable;
      extraOptions = ''
        allowed-uris = https://github.com/nix-community/ https://github.com/NixOS/
      '';
      buildMachines = [
        {
          hostName = "localhost";
          systems = [ "x86_64-linux" "builtin" ];
          maxJobs = 8;
          supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
        }
      ];
    };

    services.nginx.virtualHosts = {
      "hydra.nix-community.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString (config.services.hydra.port)}";
      };
    };

    # Create a admin user and configure a declarative project
    systemd.services.hydra-post-init = {
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "60";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "hydra-server.service" ];
      requires = [ "hydra-server.service" ];
      environment = {
        inherit (cfg.systemd.services.hydra-init.environment) HYDRA_DBI;
      };
      path = with pkgs; [ hydra-unstable netcat ];
      script = ''
        set -e
        while IFS=';' read -r user role passwordhash email fullname; do
          opts=("$user" "--role" "$role" "--password-hash" "$passwordhash")
          if [[ -n "$email" ]]; then
            opts+=("--email-address" "$email")
          fi
          if [[ -n "$fullname" ]]; then
            opts+=("--full-name" "$fullname")
          fi
          hydra-create-user "''${opts[@]}"
        done < ${cfg.services.hydra.usersFile}

        while ! nc -z localhost ${toString hydraPort}; do
          sleep 1
        done

        export HYDRA_ADMIN_PASSWORD=$(cat ${cfg.services.hydra.adminPasswordFile})
        export URL=http://localhost:${toString hydraPort}
      '' +
      (concatStringsSep "\n" (mapAttrsToList
        (n: v: ''
          export DECL_PROJECT_NAME="${n}"
          export DECL_DISPLAY_NAME="${v.displayName}"
          export DECL_VALUE="${v.inputValue}"
          export DECL_TYPE="${v.inputType}"
          export DECL_FILE="${v.specFile}"
          export DECL_DESCRIPTION="${v.description}"
          export DECL_HOMEPAGE="${v.homepage}"
          ${createDeclarativeProjectScript}/bin/create-declarative-project
        '')
        cfg.services.hydra.declarativeProjects));
    };
  };
}

{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config;

  hydraPort = 3000;
  hydraAdmin = "admin";
  hydraAdminPasswordFile = "/run/keys/hydra-admin-password";
  hydraUsersFile = "/run/keys/hydra-users";

  createDeclarativeProjectScript = pkgs.stdenv.mkDerivation {
    name = "create-declarative-project";
    unpackPhase = ":";
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = "install -m755 -D ${./create-declarative-project.sh} $out/bin/create-declarative-project";
    postFixup = ''
      wrapProgram "$out/bin/create-declarative-project" \
        --prefix PATH ":" ${pkgs.stdenv.lib.makeBinPath [ pkgs.curl ]}
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

    services.nginx.virtualHosts = {
      "hydra.nix-community.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString (hydraPort)}";
      };
    };

    services.hydra = {
      enable = true;
      hydraURL = "https://hydra.nix-community.org";
      notificationSender = "hydra@hydra.nix-community.org";
      port = hydraPort;
      useSubstitutes = true;
      adminPasswordFile = hydraAdminPasswordFile;
      package = pkgs.hydra-unstable.overrideAttrs (old:{
        # https://github.com/NixOS/hydra/pull/895
        patches = [
          (pkgs.fetchpatch {
            url = "https://github.com/NixOS/hydra/commit/6f662a606abe02c1c4918742c21eeec772e8fcfc.patch";
            sha256 = "sha256-m9+JL19yM6iITb4MiMdxnQuHH3rBfBOPx7IHr3y3xVI=";
          })
          (pkgs.fetchpatch {
            url = "https://github.com/NixOS/hydra/commit/6bb180a0f2c136375d6d2fe5ae441a7c0f949b90.patch";
            sha256 = "sha256-Q6zqeFdrjmr9dd7ISekLXIyOhUHuPFJCWfekukA7bqQ=";
          })
          (pkgs.fetchpatch {
            url = "https://github.com/NixOS/hydra/commit/425c7ff17f2f801894902184fb4b39f14c944d55.patch";
            sha256 = "sha256-A8SZzcOh2v+J44ICh/+EFILqWVlvo+DpUYYLu1ZbIto=";
          })
        ];
      });

      usersFile = hydraUsersFile;
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
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

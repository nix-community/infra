{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config;

  hydraPort = 3000;
  hydraAdmin = "admin";
  hydraAdminPasswordFile = "/var/keys/hydra-admin-password";

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

in {
  options.services.hydra = {
    adminPasswordFile = mkOption {
      type = types.str;
      description = "The initial password for the Hydra admin account";
    };

    declarativeProjects = mkOption {
      description = "Declarative projects";
      default = {};
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
    networking.firewall = {
      allowedTCPPorts = [ 443 80 ];
    };

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

    services.nginx = {
      enable = true;
      virtualHosts = {
        "hydra.nix-community.com" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString(hydraPort)}";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };

    services.hydra = {
      enable = true;
      hydraURL = "hydra.nix-community.org";
      notificationSender = "hydra@hydra.nix-community.org";
      port = hydraPort;
      useSubstitutes = true;
      adminPasswordFile = hydraAdminPasswordFile;
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
      '';
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
        supportedFeatures = [ "nixos-test" "big-parallel" ];
      }];
    };

    # Create a admin user and configure a declarative project
    systemd.services.hydra-post-init = mkIf (cfg.services.hydra.adminPasswordFile != null) {
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "60";
      };
      wantedBy = [ "multi-user.target" ];
      after = ["hydra-server.service" ];
      requires = [ "hydra-server.service" ];
      environment = {
        inherit (cfg.systemd.services.hydra-init.environment) HYDRA_DBI;
      };
      path = with pkgs; [ hydra netcat ];
      script = ''
        set -e
        export HYDRA_ADMIN_PASSWORD=$(cat ${cfg.services.hydra.adminPasswordFile})

        hydra-create-user ${hydraAdmin} --role admin --password $HYDRA_ADMIN_PASSWORD
        while ! nc -z localhost ${toString hydraPort}; do
          sleep 1
        done

        export URL=http://localhost:${toString hydraPort} 
      '' +
      (concatStringsSep "\n" (mapAttrsToList (n: v: ''
        export DECL_PROJECT_NAME="${n}"
        export DECL_DISPLAY_NAME="${v.displayName}"
        export DECL_VALUE="${v.inputValue}"
        export DECL_TYPE="${v.inputType}"
        export DECL_FILE="${v.specFile}"
        export DECL_DESCRIPTION="${v.description}"
        export DECL_HOMEPAGE="${v.homepage}"
        ${createDeclarativeProjectScript}/bin/create-declarative-project
      '') cfg.services.hydra.declarativeProjects));
    };
  };
}
    

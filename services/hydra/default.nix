{ hydra }: { lib
           , pkgs
           , config
           , ...
           }:
with lib; let
  cfg = config;

  hydraPort = 3000;

  upload-to-cachix = pkgs.writeScriptBin "upload-to-cachix" ''
    #!/bin/sh
    set -eu
    set -f # disable globbing

    # skip push if the declarative job spec
    OUT_END=$(echo ''${OUT_PATHS: -10})
    if [ "$OUT_END" == "-spec.json" ]; then
      exit 0
    fi

    export HOME=/root
    exec ${pkgs.cachix}/bin/cachix -c ${config.sops.secrets.nix-community-cachix.path} push nix-community $OUT_PATHS > /tmp/hydra_cachix 2>&1
  '';
in
{
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
  };
  config = {
    sops.secrets.hydra-admin-password.owner = "hydra";
    sops.secrets.hydra-users.owner = "hydra";

    # hydra-queue-runner needs to read this key for remote building
    sops.secrets.id_buildfarm.owner = "hydra-queue-runner";

    nix.extraOptions = ''
      builders-use-substitutes = true
      allowed-uris = https://github.com/nix-community/ https://github.com/NixOS/
      post-build-hook = ${upload-to-cachix}/bin/upload-to-cachix
    '';

    nixpkgs.config = {
      whitelistedLicenses = with lib.licenses; [
        unfreeRedistributable
        issl
      ];
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "cudnn_cudatoolkit"
          "cudatoolkit"
        ];
    };

    services.hydra.package = hydra.defaultPackage.${pkgs.system};

    sops.secrets.nix-community-cachix.sopsFile = ../../roles/nix-community-cache.yaml;
    sops.secrets.id_buildfarm = { };

    services.hydra = {
      enable = true;
      hydraURL = "https://hydra.nix-community.org";
      notificationSender = "hydra@hydra.nix-community.org";
      port = hydraPort;
      useSubstitutes = true;
      adminPasswordFile = config.sops.secrets.hydra-admin-password.path;
      usersFile = config.sops.secrets.hydra-users.path;
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
      '';
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "localhost";
          systems = [ "x86_64-linux" "builtin" ];
          maxJobs = 8;
          supportedFeatures = [ "nixos-test" "big-parallel" "kvm" ];
        }
      ];
    };

    services.postgresql = {
      enable = true;
      settings = {
        effective_cache_size = "4GB";
        shared_buffers = "4GB";
      };
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
      path = with pkgs; [ config.services.hydra.package netcat ];
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
      '';
    };
  };
}

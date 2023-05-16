{ lib, inputs, pkgs, config, ... }:
let
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
    adminPasswordFile = lib.mkOption {
      type = lib.types.str;
      description = "The initial password for the Hydra admin account";
    };

    usersFile = lib.mkOption {
      type = lib.types.str;
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

    nix.settings.allowed-uris = [
      "https://github.com/nix-community/"
      "https://github.com/NixOS/"
    ];
    nix.settings.post-build-hook = "${upload-to-cachix}/bin/upload-to-cachix";

    sops.secrets.nix-community-cachix.sopsFile = "${toString inputs.self}/modules/nixos/nix-community-cache/secrets.yaml";
    sops.secrets.id_buildfarm = { };

    # delete build logs older than 30 days
    systemd.services.hydra-delete-old-logs = {
      startAt = "Sun 05:45";
      serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /var/lib/hydra/build-logs -type f -mtime +30 -delete";
    };

    services.hydra = {
      enable = true;
      # remote builders set in /etc/nix/machines + localhost
      buildMachinesFiles = [
        "/etc/nix/machines"

        (pkgs.writeText "local" ''
          localhost x86_64-linux,builtin - 8 1 nixos-test,big-parallel,kvm - -
        '')
      ];
      hydraURL = "https://hydra.nix-community.org";
      notificationSender = "hydra@hydra.nix-community.org";
      port = 3000;
      useSubstitutes = true;
      adminPasswordFile = config.sops.secrets.hydra-admin-password.path;
      usersFile = config.sops.secrets.hydra-users.path;
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
      '';
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hydra" ];
      settings = {
        max_connections = "300";
        effective_cache_size = "4GB";
        shared_buffers = "4GB";
      };
    };

    services.nginx.virtualHosts = {
      "hydra.nix-community.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
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
        inherit (config.systemd.services.hydra-init.environment) HYDRA_DBI;
      };
      path = [ config.services.hydra.package pkgs.netcat ];
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
        done < ${config.services.hydra.usersFile}

        while ! nc -z localhost ${toString config.services.hydra.port}; do
          sleep 1
        done

        export HYDRA_ADMIN_PASSWORD=$(cat ${config.services.hydra.adminPasswordFile})
        export URL=http://localhost:${toString config.services.hydra.port}
      '';
    };
  };
}

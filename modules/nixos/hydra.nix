{ pkgs, config, ... }:
{
  config = {
    sops.secrets.hydra-admin-password.owner = "hydra";
    sops.secrets.hydra-users.owner = "hydra";

    nix.settings.allowed-uris = [
      "git+https:"
      "github:"
      "gitlab:"
      "https:"
      "sourcehut:"
    ];

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
      extraConfig = ''
        max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
      '';
    };

    services.nginx.virtualHosts = {
      "hydra.nix-community.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
      };
    };

    # Create user accounts
    # format: user;role;password-hash;email-address;full-name
    # Password hash is computed by applying sha1 to the password.
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
        done < ${config.sops.secrets.hydra-users.path}

        while ! nc -z localhost ${toString config.services.hydra.port}; do
          sleep 1
        done

        export HYDRA_ADMIN_PASSWORD=$(cat ${config.sops.secrets.hydra-admin-password.path})
        export URL=http://localhost:${toString config.services.hydra.port}
      '';
    };
  };
}

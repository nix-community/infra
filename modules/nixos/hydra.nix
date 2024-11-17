{ pkgs, config, ... }:
{
  sops.secrets.hydra-admin-password.owner = "hydra";
  sops.secrets.hydra-users.owner = "hydra";

  # hydra-queue-runner needs to read this key for remote building
  sops.secrets.id_buildfarm.owner = "hydra-queue-runner";

  nix.settings.keep-outputs = pkgs.lib.mkForce false;

  nix.settings.allowed-uris = [
    "git+https:"
    "github:"
    "gitlab:"
    "https:"
    "sourcehut:"
  ];

  sops.secrets.id_buildfarm = { };

  # delete build logs older than 30 days
  systemd.services.hydra-delete-old-logs = {
    startAt = "Sun 05:45";
    serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /var/lib/hydra/build-logs -type f -mtime +30 -delete";
  };

  # not currently needed
  systemd.services = {
    hydra-check-space.enable = false;
    hydra-notify.enable = false;
    hydra-send-stats.enable = false;
  };

  services.hydra = {
    enable = true;
    # remote builders set in /etc/nix/machines + localhost
    buildMachinesFiles = [
      (pkgs.runCommand "etc-nix-machines" { machines = config.environment.etc."nix/machines".text; } ''
        printf "$machines" | grep build04 > $out
        substituteInPlace $out --replace-fail 'ssh-ng://' 'ssh://'
        substituteInPlace $out --replace-fail ' 80 ' ' 3 '
      '')

      (pkgs.writeText "local" ''
        localhost x86_64-linux,builtin - 3 1 ${pkgs.lib.concatStringsSep "," config.nix.settings.system-features} - -
      '')
    ];
    hydraURL = "https://hydra.nix-community.org";
    notificationSender = "hydra@hydra.nix-community.org";
    port = 3000;
    useSubstitutes = true;
    extraConfig = ''
      evaluator_max_memory_size = 4096
      evaluator_workers = 8
      max_concurrent_evals = 2
      max_output_size = ${builtins.toString (8 * 1024 * 1024 * 1024)}
    '';
  };

  services.nginx.virtualHosts."hydra.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:${toString config.services.hydra.port}";
  };

  # Create user accounts
  # format: user;role;password-hash;email-address;full-name
  # Password hash is computed by applying sha1 to the password.
  systemd.services.hydra-post-init = {
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "60";
    };
    wantedBy = [ config.systemd.targets.multi-user.name ];
    after = [ config.systemd.services.hydra-server.name ];
    requires = [ config.systemd.services.hydra-server.name ];
    environment = {
      inherit (config.systemd.services.hydra-init.environment) HYDRA_DBI;
    };
    path = [
      config.services.hydra.package
      pkgs.netcat
    ];
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
}

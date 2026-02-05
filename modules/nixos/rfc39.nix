{
  config,
  inputs,
  pkgs,
  ...
}:
{
  sops.secrets.rfc39-app-private-key = {
    format = "binary";
    owner = "rfc39";
    sopsFile = "${inputs.self}/modules/secrets/rfc39_private_key.der";
  };

  sops.secrets.rfc39-record-ssh-key = {
    owner = "rfc39";
  };

  users.users.rfc39 = {
    description = "rfc39 maintainer team sync";
    home = "/var/lib/rfc39";
    createHome = true;
    isSystemUser = true;
    group = "rfc39";
  };
  users.groups.rfc39 = { };

  systemd.services.rfc39-sync = {
    description = "sync maintainer teams";
    path = [
      config.nix.package
      pkgs.git
      pkgs.openssh
      pkgs.rfc39
    ];
    startAt = "hourly";
    serviceConfig.User = "rfc39";
    serviceConfig.Group = "rfc39";
    serviceConfig.Type = "oneshot";
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "1m";
    serviceConfig.PrivateTmp = true;
    environment = {
      RFC39_CREDENTIALS = pkgs.writeText "rfc39_credentials" ''
        {
          app_id = 1293458;
          private_key_file = "${config.sops.secrets.rfc39-app-private-key.path}";
          installation_id = 67339230;
        }
      '';
      RFC39_RECORD_SSH_KEY = config.sops.secrets.rfc39-record-ssh-key.path;
    };
    script = builtins.readFile ./rfc39.bash;
  };
}

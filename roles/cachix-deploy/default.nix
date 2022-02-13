{ config, pkgs, ... }: {
  sops.secrets.cachix-agent-token.sopsFile = ./secrets.yaml;

  # We don't restart cachix-deploy-agent on upgrades.
  # So we do it at random points in time instead.
  # Also helps with connection failures.
  systemd.services.cachix-deploy-restart = {
    wantedBy = [ "multi-user.target" ];
    startAt = "hourly";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        # sleep in case we are restarted by an upgrade process.
        "${pkgs.coreutils}/bin/sleep 600"
        "${config.systemd.package}/bin/systemctl restart cachix-deploy-agent"
      ];
    };
  };

  systemd.services.cachix-deploy-agent = {
    wantedBy = [ "multi-user.target" ];
    path = [ config.nix.package ];
    restartIfChanged = false;
    serviceConfig = {
      Restart = "on-failure";
      Environment = "USER=root";
      EnvironmentFile = config.sops.secrets.cachix-agent-token.path;
      ExecStart = "${pkgs.cachix}/bin/cachix deploy agent ${config.networking.hostName}";
    };
  };
}

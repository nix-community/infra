{ config, pkgs, ... }: {
  sops.secrets.cachix-agent-token.sopsFile = ./secrets.yaml;

  systemd.services.cachix-deploy-agent = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.cachix-agent-token.path;
      ExecStart = "${pkgs.cachix}/bin/cachix deploy agent ${config.networking.hostName}";
    };
  };
}

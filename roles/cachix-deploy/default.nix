{ config, ... }: {
  sops.secrets.cachix-agent-token.sopsFile = ./secrets.yaml;

  systemd.services.cachix-deploy-agent = let
    sources = import ../../nix/sources.nix {};
  in {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.cachix-agent-token.path;
      ExecStart = "${import sources.cachix {}}/bin/cachix deploy agent ${config.networking.hostName}";
    };
  };
}

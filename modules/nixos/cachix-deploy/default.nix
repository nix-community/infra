{ config, ... }:
{
  sops.secrets.cachix-agent-token.sopsFile = ./secrets.yaml;

  services.cachix-agent = {
    enable = true;
    credentialsFile = config.sops.secrets.cachix-agent-token.path;
  };

  system.autoUpgrade.enable = false;
}

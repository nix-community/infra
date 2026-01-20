{ config, ... }:

{
  sops.secrets.cachix-auth-token = { };

  services.cachix-watch-store = {
    enable = true;
    cacheName = "nix-community";
    cachixTokenFile = config.sops.secrets.cachix-auth-token.path;
  };

  systemd.services.cachix-watch-store-agent.enableStrictShellChecks = false;
}

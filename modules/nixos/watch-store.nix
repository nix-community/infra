{ config, ... }:

{
  sops.secrets.watch-store-token = { };

  services.cachix-watch-store = {
    enable = true;
    cacheName = "nix-community";
    cachixTokenFile = config.sops.secrets.watch-store-token.path;
  };
}

{ config, ... }:

{
  sops.secrets.watch-store-token.sopsFile = ./secrets.yaml;

  services.cachix-watch-store = {
    enable = true;
    cacheName = "nix-community";
    cachixTokenFile = config.sops.secrets.watch-store-token.path;
  };
}

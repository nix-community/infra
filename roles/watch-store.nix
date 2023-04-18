{ config, pkgs, ... }:

{
  sops.secrets.watch-store-token.sopsFile = ./nix-community-cache/secrets.yaml;

  services.cachix-watch-store = {
    enable = true;
    cacheName = "nix-community";
    cachixTokenFile = config.sops.secrets.watch-store-token.path;
    package = pkgs.haskellPackages.cachix_1_3_3;
  };
}

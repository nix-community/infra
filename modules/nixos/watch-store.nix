{ config, inputs, ... }:

{
  age.secrets.cachix-auth-token = {
    file = "${inputs.self}/secrets/cachix-auth-token.age";
  };

  services.cachix-watch-store = {
    enable = true;
    cacheName = "nix-community";
    cachixTokenFile = config.age.secrets.cachix-auth-token.path;
  };
}

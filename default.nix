# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem }:
let
  pkgs = import ./nix { inherit system; };

  importNixOS = configuration: system:
    (import "${toString pkgs.path}/nixos") {
      inherit configuration system;
    };
in
pkgs.nix-community-infra // rec {
  build01 = pkgs.nixos [ ./build01/configuration.nix ];
  build02 = pkgs.nixos [ ./build02/configuration.nix ];
}

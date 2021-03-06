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
  build01 = importNixOS ./build01/configuration.nix "x86_64-linux";
  build01-system = build01.system;
  build02 = importNixOS ./build02/configuration.nix "x86_64-linux";
  build02-system = build02.system;
  build03 = importNixOS ./build02/configuration.nix "x86_64-linux";
  build03-system = build03.system;
}

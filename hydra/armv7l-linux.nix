# nix-eval-jobs --force-recurse -I . hydra/armv7l-linux.nix --arg nixpkgs /path/to/nixpkgs
{
  nixpkgs,
  packageSet ? import nixpkgs,
  nixpkgsArgs ? {
    config = {
      allowAliases = false;
      allowUnfree = false;
      inHydra = true;
    };
    __allowFileset = false;
  },
  supportedSystems ? [
    "armv7l-linux"
  ],
}:
let
  inherit
    (import (nixpkgs + "/pkgs/top-level/release-lib.nix") {
      inherit nixpkgsArgs packageSet supportedSystems;
    })
    all
    mapTestOn
    ;
in
mapTestOn {
  # keep-sorted start
  stdenv = all;
  # keep-sorted end
}

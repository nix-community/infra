# nix-eval-jobs --force-recurse -I . hydra/release-linux.nix --arg nixpkgs /path/to/nixpkgs
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
    "aarch64-linux"
    "x86_64-linux"
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

  build = {
    # keep-sorted start
    cargo = all;
    git = all;
    go = all;
    linux = all;
    linux_latest = all;
    lix = all;
    nix = all;
    nixosTests.simple = all;
    python3 = all;
    shellcheck = all;
    stdenv = all;
    # keep-sorted end
  };
in
mapTestOn {
  pkgsLLVM = build;
  pkgsMusl = build;
  pkgsStatic = build;
}

# nix-eval-jobs --force-recurse -I . hydra/bsd.nix --arg nixpkgs /path/to/nixpkgs
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
    "x86_64-freebsd"
  ],
}:
let
  inherit
    (import (nixpkgs + "/pkgs/top-level/release-lib.nix") {
      inherit nixpkgsArgs packageSet supportedSystems;
    })
    all
    mapTestOn
    packagePlatforms
    ;
in
mapTestOn {
  # keep-sorted start
  cargo = all;
  freebsd = packagePlatforms (packageSet { }).freebsd;
  git = all;
  go = all;
  nginx = all;
  nixVersions.latest = all;
  nixVersions.stable = all;
  openssh = all;
  perl = all;
  postgresql = all;
  python3 = all;
  stdenv = all;
  # keep-sorted end
}

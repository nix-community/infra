{ pkgs, lib, ... }:
{
  nix.settings.substituters = [ "https://nix-community.cachix.org/" ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  nix.settings.experimental-features = lib.mkForce [
    "nix-command"
    "flakes"
  ];
  nix.settings.sandbox =
    if pkgs.stdenv.isLinux
    then "relaxed"
    else false;
}

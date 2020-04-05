{ system ? builtins.currentSystem }:
let
  sources = import ./sources.nix;

  pkgs = import sources.nixpkgs {
    inherit system;
    config = {};
    overlays = [ (import ./overlay.nix) ];
  };
in
  pkgs

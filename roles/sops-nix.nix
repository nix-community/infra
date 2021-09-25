{ config, lib, pkgs, ... }:
let
  sources = import ../nix/sources.nix;
  hostDir = lib.head (builtins.match "nix-community-(.*)" config.networking.hostName);
  defaultSopsPath = ../. + "/${hostDir}/secrets.yaml";
in
{
  imports = [ "${sources.sops-nix}/modules/sops" ];
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

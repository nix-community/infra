{ config, lib, pkgs, ... }:
let
  hostDir = lib.head (builtins.match "nix-community-(.*)" config.networking.hostName);
  defaultSopsPath = ../. + "/${hostDir}/secrets.yaml";
in
{
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

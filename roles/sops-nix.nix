{ config, lib, ... }:
let
  defaultSopsPath = ../. + "/${config.networking.hostName}/secrets.yaml";
in
{
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

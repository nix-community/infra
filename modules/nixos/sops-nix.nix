{ config, inputs, lib, ... }:
let
  defaultSopsPath = "${toString inputs.self}/hosts/${config.networking.hostName}/secrets.yaml";
in
{
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

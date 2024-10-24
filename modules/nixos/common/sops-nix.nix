{
  config,
  inputs,
  lib,
  ...
}:
let
  defaultSopsPath = "${inputs.self}/hosts/${config.networking.hostName}/secrets.yaml";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

{ inputs, config, lib, ... }:
let
  defaultSopsPath = ../../. + "/${config.networking.hostName}/secrets.yaml";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}

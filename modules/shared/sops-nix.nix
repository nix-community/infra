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
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;

  sops.age.sshKeyPaths = [ ];
}

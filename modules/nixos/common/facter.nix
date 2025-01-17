{
  config,
  inputs,
  lib,
  ...
}:
let
  reportPath = "${inputs.self}/hosts/${config.networking.hostName}/report.json";
in
{
  imports = [ inputs.nixos-facter-modules.nixosModules.facter ];

  config = lib.mkIf (builtins.pathExists reportPath) {
    facter = { inherit reportPath; };
  };
}

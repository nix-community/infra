{
  config,
  inputs,
  lib,
  ...
}:
let
  report = "${inputs.self}/hosts/${config.networking.hostName}/report.json";
in
{
  imports = [ inputs.nixos-facter-modules.nixosModules.facter ];

  facter.reportPath = lib.mkIf (builtins.pathExists report) report;
}

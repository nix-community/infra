{ inputs, ... }:
{
  imports = [
    inputs.srvos.darwinModules.mixins-telegraf
    ../../shared/telegraf.nix
  ];
}

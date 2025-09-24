{ inputs, ... }:
{
  imports = [
    inputs.srvos.darwinModules.mixins-telegraf
    ../../shared/telegraf.nix
  ];

  # https://github.com/influxdata/telegraf/issues/17607
  launchd.daemons.telegraf.environment.HOME = "/var/root";
}

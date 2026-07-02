{ config, ... }:
{
  imports = [ ../../shared/free-space.nix ];

  # use fast-nix-gc for gc and optimise
  nix.gc.automatic = false;
  nix.settings.auto-optimise-store = false;

  launchd.daemons.free-space = {
    serviceConfig = {
      StartCalendarInterval = [ { Minute = 15; } ];
    };
    command = config.nixCommunity.free-space-cmd;
  };

  # https://github.com/nix-darwin/nix-darwin/blob/230a197063de9287128e2c68a7a4b0cd7d0b50a7/modules/nix/default.nix#L201
  nix.daemonProcessType = "Interactive";
}

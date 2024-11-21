{
  config,
  inputs,
  pkgs,
  ...
}:
{
  nix.gc.automatic = false;

  launchd.daemons.free-space = {
    serviceConfig = {
      StartCalendarInterval = [ { Minute = 15; } ];
    };
    path = [
      config.nix.package
      pkgs.coreutils
    ];
    script = builtins.readFile "${inputs.self}/modules/shared/free-space.bash";
  };

  # https://github.com/LnL7/nix-darwin/blob/230a197063de9287128e2c68a7a4b0cd7d0b50a7/modules/nix/default.nix#L201
  nix.daemonProcessType = "Interactive";
}

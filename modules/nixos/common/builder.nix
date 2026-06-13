{
  config,
  lib,
  ...
}:
{
  imports = [ ../../shared/free-space.nix ];

  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    # use fast-nix-gc for gc and optimise
    nix.gc.automatic = false;
    nix.settings.auto-optimise-store = false;

    # kernel samepage merging
    hardware.ksm.enable = true;

    hardware.rasdaemon.enable = true;
    services.telegraf.extraConfig.inputs.ras = { };

    systemd.services.free-space = {
      serviceConfig.Type = "oneshot";
      startAt = "hourly";
      serviceConfig.ExecStart = config.nixCommunity.free-space-cmd;
    };

    # Bump the open files limit so that non-root users can run NixOS VM tests
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "20480";
      }
    ];
  };
}

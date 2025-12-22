{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (lib.hasPrefix "build" config.networking.hostName) {
    nix.gc.automatic = false;

    # kernel samepage merging
    hardware.ksm.enable = true;

    hardware.rasdaemon.enable = true;
    services.telegraf.extraConfig.inputs.ras = { };

    system.switch.inhibitors = [
      config.hardware.firmware
    ];

    systemd.services.free-space = {
      serviceConfig.Type = "oneshot";
      startAt = "hourly";
      path = [
        config.nix.package
        pkgs.coreutils
      ];
      script = builtins.readFile "${inputs.self}/modules/shared/free-space.bash";
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

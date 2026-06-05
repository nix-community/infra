{
  config,
  lib,
  pkgs,
  ...
}:
{
  # adapted from:
  # https://github.com/Mic92/dotfiles/blob/020180880d9413e076073889f82c4751a27734e9/nixos/modules/update-prefetch.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/system/boot/kexec.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix
  systemd.services.update-host = {
    enable = true;
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "30s";
    serviceConfig.Type = "oneshot";
    path = [
      config.nix.package
      config.system.build.nixos-rebuild
      config.systemd.package
      pkgs.coreutils
      pkgs.curl
      pkgs.kexec-tools
    ];
    script = builtins.readFile ./update.bash;
  };

  systemd.timers.update-host = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnBootSec = "5m";
    timerConfig.OnUnitInactiveSec = "5m";
  };

  system.switch.inhibitors = {
    fstab = toString config.environment.etc.fstab.source;
    initrd = toString config.system.build.initialRamdisk;
    kernel = toString config.system.build.kernel;
    kernel-params = toString config.boot.kernelParams;
    modules = toString config.system.modulesTree;
    systemd = toString config.systemd.package;
  }
  // lib.optionalAttrs (lib.hasPrefix "build" config.networking.hostName) {
    firmware = toString config.hardware.firmware;
  };

  # TODO: upstream?
  system.systemBuilderCommands =
    let
      script = pkgs.writeShellScript "switch-inhibitors-script" config.system.preSwitchChecks.switchInhibitors;

      check = pkgs.writeShellScript "check-switch-inhibitors" ''
        exec ${script} "$(dirname "$0")"
      '';
    in
    ''
      ln -s ${check} $out/check-switch-inhibitors
    '';
}

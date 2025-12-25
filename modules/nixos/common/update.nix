{ config, pkgs, ... }:
{
  imports = [ ./inhibitors.nix ];

  # adapted from:
  # https://github.com/Mic92/dotfiles/blob/020180880d9413e076073889f82c4751a27734e9/nixos/modules/update-prefetch.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/system/boot/kexec.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix

  system.switch.inhibitors = [
    config.system.build.initialRamdisk
    config.system.build.kernel
    config.system.modulesTree
    (pkgs.writeTextFile {
      name = "etc/fstab";
      inherit (config.environment.etc.fstab) text;
    })
    (pkgs.writeTextFile {
      name = "kernel-params";
      text = pkgs.lib.concatStringsSep " " config.boot.kernelParams;
    })
  ];

  systemd.services.update-host = {
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "30s";
    serviceConfig.Type = "oneshot";
    path = [
      config.nix.package
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
}

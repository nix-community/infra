{ config, pkgs, ... }:
{
  # adapted from https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix
  systemd.services.reboot-after-update = {
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Type = "oneshot";
    script = ''
      booted="$(${pkgs.coreutils}/bin/readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(${pkgs.coreutils}/bin/readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
      if [ "''${booted}" != "''${built}" ]; then
        ${config.systemd.package}/bin/shutdown -r now
      fi
    '';
    startAt = "0/6:00";
  };
  systemd.timers.reboot-after-update = {
    timerConfig.RandomizedDelaySec = "6h";
  };
}

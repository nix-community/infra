{ config, pkgs, ... }:
{
  # adapted from:
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/system/boot/kexec.nix
  # https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix
  systemd.services.reboot-after-update = {
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Type = "oneshot";
    path = [ config.systemd.package pkgs.coreutils pkgs.kexec-tools ];
    script = ''
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules} && cat /run/booted-system/kernel-params)"
      p="$(readlink -f /nix/var/nix/profiles/system)"
      built="$(readlink $p/{initrd,kernel,kernel-modules} && cat $p/kernel-params)"
      if [ "''${booted}" != "''${built}" ]; then
        # don't use kexec if system is virtualized
        systemd-detect-virt -q || kexec --load $p/kernel --initrd=$p/initrd --append="$(cat $p/kernel-params) init=$p/init"
        systemctl reboot
      fi
    '';
    startAt = "hourly";
  };
  systemd.timers.reboot-after-update = {
    timerConfig.RandomizedDelaySec = "2h";
  };
}

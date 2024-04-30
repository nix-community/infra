{ config, pkgs, ... }:
{
  # adapted from https://github.com/NixOS/nixpkgs/blob/3428bdf3c93a7608615dddd44dec50c3df89b4be/nixos/modules/tasks/auto-upgrade.nix
  systemd.services.reboot-after-update = {
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig.Type = "oneshot";
    path = [ config.systemd.package pkgs.coreutils ];
    script = ''
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules} && cat /run/booted-system/kernel-params)"
      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules} && cat /nix/var/nix/profiles/system/kernel-params)"
      if [ "''${booted}" != "''${built}" ]; then
        systemctl reboot
      fi
    '';
    startAt = "0/3:00";
  };
  systemd.timers.reboot-after-update = {
    timerConfig.RandomizedDelaySec = "3h";
  };
}

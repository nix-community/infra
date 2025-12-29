{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    ./armv7l.nix
    ./builder.nix
    ./cgroups.nix
    ./kernel.nix
    ./security.nix
    ./sops-nix.nix
    ./telegraf.nix
    ./update.nix
    ./users.nix
    inputs.srvos.nixosModules.server
  ];

  # Hard-link duplicated files
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = false;

  # Sometimes it fails if a store path is still in use.
  # This should fix intermediate issues.
  systemd.services.nix-gc.serviceConfig = {
    Restart = "on-failure";
  };

  system.etc.overlay = {
    enable = true;
    mutable = false;
  };
  services.userborn.enable = true;
  system.nixos-init.enable = true;

  boot.kernelPackages = pkgs.lib.mkIf (
    !config.boot.supportedFilesystems.zfs or false
  ) pkgs.linuxPackages_latest;

  services.dbus.implementation = "broker";

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  systemd.tmpfiles.rules = [ "D! /nix/var/nix/builds 0755 root root" ];

  systemd.services.sysctl-after-boot = {
    serviceConfig.Restart = "on-failure";
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.procps
    ];
    script = ''
      sysctl -w kernel.hardlockup_panic=1
      sysctl -w kernel.panic_on_oops=1
      sysctl -w kernel.panic=60
      sysctl -w kernel.softlockup_panic=1
    '';
  };

  systemd.timers.sysctl-after-boot = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnBootSec = "5m";
  };

  # https://github.com/NixOS/nixpkgs/pull/268121
  # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0;
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  networking.domain = "nix-community.org";
}

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
    ./reboot.nix
    ./security.nix
    ./sops-nix.nix
    ./telegraf.nix
    ./users.nix
    inputs.sops-nix.nixosModules.sops
    inputs.agenix.nixosModules.age
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

  boot.kernelPackages = pkgs.lib.mkIf (
    !config.boot.supportedFilesystems.zfs or false
  ) pkgs.linuxPackages_latest;

  zramSwap.enable = true;

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

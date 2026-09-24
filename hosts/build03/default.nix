{ inputs, pkgs, ... }:
{
  imports = [
    ./cache-harmonia.nix
    ./hydra.nix
    ./hydra-post-init.nix
    ./postgresql.nix
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.self.nixosModules.freebsd-builder
    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nixbot
    inputs.self.nixosModules.watch-store
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    ./hydra-ad-hoc.nix
  ];

  nix.package = pkgs.nixVersions.latest;

  nix.settings.extra-platforms = [ "i686-linux" ];

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  nix.settings.max-jobs = 96;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./nixpkgs-update-backup.nix
    ./nixpkgs-update-cache.nix
    ./nixpkgs-update.nix
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  boot.zfs.package = pkgs.zfs_2_4;

  nix.settings.auto-optimise-store = lib.mkForce false;

  nix.settings.cores = config.nix.settings.max-jobs / 3 * 2;
  nix.settings.max-jobs = 24;

  boot.kernelParams = [ "zfs.zfs_arc_max=${toString (24 * 1024 * 1024 * 1024)}" ]; # 24GB, try to limit OOM kills / reboots

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:41d9::1";

  system.stateVersion = "23.11";
}

{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    ./nixpkgs-update.nix
    ./nixpkgs-update-backup.nix
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.disko-zfs
  ];

  # set in srvos, remove when reinstalling
  networking.hostId = "deadbeef";

  nixCommunity.gc.gbFree = 500;

  boot.kernelParams = [ "zfs.zfs_arc_max=${toString (24 * 1024 * 1024 * 1024)}" ]; # 24GB, try to limit OOM kills / reboots

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:41d9::1";

  system.stateVersion = "23.11";
}

{ ... }:

{
  imports = [
    ./nixpkgs-update.nix
    ./nixpkgs-update-backup.nix
    ../roles/common.nix
    ../roles/hercules-ci
    ../roles/zfs-raid.nix
    ../roles/remote-builder/aarch64-build04.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "build02";
  networking.hostId = "af9ccc71";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:4a:2b02::1/64";

  system.stateVersion = "20.09";
}

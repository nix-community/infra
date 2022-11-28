{ config, pkgs, lib, ... }:

{
  imports = [
    ../roles/common.nix
    ../roles/hardware/hetzner-amd.nix
    ../roles/hetzner-network.nix
    ../roles/nginx.nix
    ../roles/raid.nix
    ../roles/remote-builder/aarch64-build04.nix
  ];

  # We often see evals going out-of-memory. So let's try zram swap
  zramSwap.enable = true;

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "build02";
  networking.hostId = "af9ccc71";
  networking.useDHCP = false;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  networking.nix-community.ipv6.address = "2a01:4f9:4a:2b02::1";

  system.stateVersion = "20.09";
}

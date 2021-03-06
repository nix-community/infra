{ config, pkgs, lib, ... }:
{
  # Boot recovery:
  # Activate 64-bit Rescue system in https://robot.your-server.de/server
  # ssh root@build03.nix-community.org "mount /dev/md0 /mnt && /mnt/kexec_bundle"
  #
  # In kexec image:
  # zpool import -f zroot && mount -t zfs zroot/root/nixos /mnt && mount -t zfs zroot/root/home /mnt/home && mount /dev/md0 /mnt/boot
  # nixos-enter
  imports = [
    ./hardware-configuration.nix

    ../profiles/common.nix
    ../profiles/hetzner-network.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.extraConfig = ''
    # for mdraid 1.1
    insmod mdraid1x
  '';

  networking.nix-community = {
    ipv4.address = "135.181.218.169";
    ipv4.gateway = "135.181.218.129";
    ipv6.address = "2a01:4f9:3a:3b16::1";
  };

  networking.hostName = "nix-community-build03";
  networking.hostId = "8daf74c0";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "zfs" ];

  system.stateVersion = "21.05";
}

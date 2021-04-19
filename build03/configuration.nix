{ config, pkgs, lib, ... }:
{
  # Boot recovery:
  # Activate 64-bit Rescue system in https://robot.your-server.de/server
  # ssh root@build03.nix-community.org "mount /dev/md[0-9]* /mnt && /mnt/kexec_bundle"
  #
  # In kexec image:
  # stop autoreboot:
  # $ systemctl stop autoreboot.timer
  # $ zpool import -f zroot && mount -t zfs zroot/root/nixos /mnt && mount -t zfs zroot/root/home /mnt/home && mount /dev/md[0-9]* /mnt/boot
  # $ nixos-enter
  imports = [
    ./hardware-configuration.nix

    ../roles/buildkite.nix
    ../roles/common.nix
    ../roles/hetzner-network.nix
    ../roles/nginx.nix
    ../roles/nix-community-cache.nix

    ../services/hound
    ../services/matterbridge.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.extraConfig = ''
    # for mdraid 1.1
    insmod mdraid1x
  '';

  networking.nix-community.ipv6.address = "2a01:4f9:3a:3b16::1";

  networking.hostName = "nix-community-build03";
  networking.hostId = "8daf74c0";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "21.05";
}

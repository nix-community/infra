{ config, pkgs, lib, ... }:
# Boot recovery:
# Activate 64-bit Rescue system in https://robot.your-server.de/server
# ssh root@build01.nix-community.org "mount /dev/md[0-9]* /mnt && /mnt/kexec_bundle"
#
#
# In kexec image:
# # stop autoreboot
# $ systemctl stop autoreboot.timer
# $ zpool import -f zroot && mount -t zfs zroot/root /mnt && mount -t zfs zroot/root/home /mnt/home && mount -t zfs zroot/root/nix /mnt/nix && mount /dev/md[0-9]* /mnt/boot
# nixos-enter
{
  imports = [
    ../roles/dev-packages.nix
    ../roles/common.nix
    ../roles/hardware/hetzner-amd.nix
    ../roles/hetzner-network.nix
    ../roles/raid.nix
    ../roles/builder
    ../roles/remote-builder/aarch64-nixos-community.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "build01";
  networking.hostId = "d2905767";

  # Emulate armv7 until we have proper builders
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  networking.nix-community.ipv6.address = "2a01:4f8:13b:2ceb::1";

  system.stateVersion = "20.03";
}

{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../roles/common.nix
    ../roles/hercules-ci
    ../roles/remote-builder/user.nix
  ];

  nixpkgs.system = "aarch64-linux";

  # disable default features
  nix.settings.system-features = [ ];

  # we use grub because systemd-boot sometimes fail on aarch64/EFI
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.version = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
    terminal_input --append serial
    terminal_output --append serial
  '';

  networking.hostName = "build04";
  networking.hostId = "8daf74c0";

  networking.usePredictableInterfaceNames = false;
  # networkd chokes on some ipv6 messages that the oracle network sends
  networking.dhcpcd.enable = true;

  system.stateVersion = "21.11";
}

# after loading kexec, be patient. The kexec image can take up to 5 minutes to boot
# partition guide
/*
  sgdisk -n 1:0:+800M -N 2 -t 1:ef00 -t 2:8304 /dev/sda
  mkfs.vfat -b32 /dev/sda1
  zpool create zroot -O acltype=posixacl -O xattr=sa -O compression=lz4 /dev/sda2
  zfs create -o mountpoint=none zroot/root
  zfs create -o mountpoint=legacy zroot/root/nixos
  zfs create -o mountpoint=legacy zroot/root/home
  mount -t zfs zroot/root/nixos /mnt
  mkdir /mnt/{home,boot}
  mount -t zfs zroot/root/home /mnt/home
  mount /dev/sda1 /mnt/boot
*/

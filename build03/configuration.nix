{ ... }:
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
    ../roles/common.nix
    ../roles/hercules-ci
    ../roles/watch-store.nix
    ../roles/raid.nix
    ../roles/zfs.nix
    ../roles/remote-builder/aarch64-build04.nix

    ../services/hydra
    ../services/nur-update
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  networking.hostName = "build03";
  networking.hostId = "8daf74c0";

  system.stateVersion = "21.05";
}

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./buildkite.nix

    ../profiles/common.nix
    ../profiles/docker.nix

    ../users/adisbladis.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "nix-community-build01";
  networking.hostId = "d2905767";

  networking.usePredictableInterfaceNames = false;
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    networks."eth0".extraConfig = ''
      [Match]
      Name = eth0
      [Network]
      Address =  2a01:4f8:13b:2ceb::1/64
      Gateway = fe80::1
      Address =  94.130.143.84/26
      Gateway = 94.130.143.65
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "zfs" ];

  system.stateVersion = "19.09";

}

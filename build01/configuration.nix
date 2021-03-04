{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./buildkite.nix
    ./gitlab.nix
    ./hydra.nix
    ./hydra-declarative-projects.nix
    ./cache.nix
    ./marvin-mk2.nix
    ./matterbridge.nix

    ../profiles/common.nix
    ../services/docker.nix
    ../services/hound
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "nix-community-build01";
  networking.hostId = "d2905767";

  networking.usePredictableInterfaceNames = false;
  networking.dhcpcd.enable = false;

  # Emulate armv7 until we have proper builders
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  networking.firewall = {
    # for Nginx
    allowedTCPPorts = [ 443 80 ];
  };

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

  # nginx is being used as the frontend HTTP server for all the services
  # running on the box
  services.nginx.enable = true;

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    # record that this machine is alive
    "*/5 * * * * root ${pkgs.curl}/bin/curl -X POST -sfL https://hc-ping.com/fcf6c029-5b57-44aa-b392-923f3d894dd9"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "zfs" ];

  system.stateVersion = "20.03";
}

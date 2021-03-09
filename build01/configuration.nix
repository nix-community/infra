{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../roles/buildkite.nix
    ../roles/common.nix
    ../roles/docker.nix
    ../roles/gitlab-runner.nix
    ../roles/hetzner-network.nix
    ../roles/nginx.nix
    ../roles/nix-community-cache.nix

    ../services/hydra
    ../services/marvin-mk2.nix
    ../services/matterbridge.nix
  ];

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "nix-community-build01";
  networking.hostId = "d2905767";

  # Emulate armv7 until we have proper builders
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  networking.nix-community = {
    ipv4.address = "94.130.143.84";
    ipv4.gateway = "94.130.143.65";
    ipv6.address = "2a01:4f8:13b:2ceb::1";
  };

  systemd.services.healthcheck-ping = {
    startAt = "*:0/5"; # every 5 minutes
    serviceConfig.ExecStart = "${pkgs.curl}/bin/curl -X POST -sfL https://hc-ping.com/fcf6c029-5b57-44aa-b392-923f3d894dd9";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "20.03";
}

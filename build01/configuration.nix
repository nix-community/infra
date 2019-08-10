{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./buildkite.nix
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

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtr+rcxCZBAAqt8ocvhEEdBWfnRBCljjQPtC6Np24Y3H/HMe3rugsu3OhPscRV1k5hT+UlA2bpN8clMFAfK085orYY7DMUrgKQzFB7GDnOvuS1CqE1PRw7/OHLcWxDwf3YLpa8+ZIwMHFxR2gxsldCLGZV/VukNwhEvWs50SbXwVrjNkwA9LHy3Or0i6sAzU711V3B2heB83BnbT8lr3CKytF3uyoTEJvDE7XMmRdbvZK+c48bj6wDaqSmBEDrdNncsqnReDjScdNzXgP1849kMfIUwzXdhEF8QRVfU8n2A2kB0WRXiGgiL4ba5M+N9v1zLdzSHcmB0veWGgRyX8tN cardno:000607203159" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "zfs" ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

  system.stateVersion = "18.03"; # Did you read the comment?

}

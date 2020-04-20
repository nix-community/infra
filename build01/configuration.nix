{ config, pkgs, lib, ... }:

let
  userImports =
    let
      toUserPath = f: ../users/. + "/${f}";
      onlyUserFiles = x:
        lib.hasSuffix ".nix" x &&
        x != "lib.nix"
        ;
      userDirEntries = builtins.readDir ../users;
      userFiles = builtins.filter onlyUserFiles (lib.attrNames userDirEntries);
    in
    builtins.map toUserPath userFiles;
in
{
  imports = [
    ./hardware-configuration.nix

    ./buildkite.nix
    ./gitlab.nix
    ./hydra.nix
    ./hydra-declarative-projects.nix
    ./cache.nix
    ./nixpkgs-update.nix

    ../profiles/common.nix
    ../profiles/docker.nix
  ] ++ userImports;

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

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    # record that this machine is alive
    "*/5 * * * * root ${pkgs.curl}/bin/curl -X POST -sfL https://hc-ping.com/fcf6c029-5b57-44aa-b392-923f3d894dd9"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "zfs" ];

  security.acme.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  system.stateVersion = "20.03";

}

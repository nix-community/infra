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

    ./cache.nix
    ./nixpkgs-update.nix

    ../profiles/common.nix
  ] ++ userImports;

  # /boot is a mirror raid
  boot.loader.grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.hostName = "nix-community-build02";
  networking.hostId = "af9ccc71";
  networking.useDHCP = false;
  networking.defaultGateway = "95.217.109.129";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp35s0";
  };
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.interfaces."enp35s0" = {
    ipv4.addresses = [ { address = "95.217.109.189"; prefixLength = 26; } ];
    ipv6.addresses = [
      { address = "fe80::aaa1:59ff:fe0e:aa61"; prefixLength = 64; }
      { address = "2a01:4f9:4a:2b02::1"; prefixLength = 64; }
    ];
  };

  # nginx is being used as the frontend HTTP server for all the services
  # running on the box
  services.nginx.enable = true;
  networking.firewall = {
    # for Nginx
    allowedTCPPorts = [ 443 80 ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  security.acme.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  system.stateVersion = "20.09";

}

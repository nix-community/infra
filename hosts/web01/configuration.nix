{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    inputs.self.nixosModules.common
    inputs.srvos.nixosModules.mixins-nginx
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = false;

  # Make it easier to recover via serial console in case something goes wrong.
  services.getty.autologinUser = "root";

  networking.hostName = "web01";

  system.stateVersion = "23.11";
  systemd.network = {
    enable = true;
    networks.ethernet.extraConfig = ''
      [Match]
      Type = ether
      [Network]
      DHCP = yes
      IPv6AcceptRA = true
      # Usually dhcpv6 should give us a public address, but it doesn't seem to work for oracle with both networkd/dhcpcd
      # so we set it manually here. One can get the address by clicking on the primary vnic in the oracle console and
      # under Resources -> IPv6 Addresses
      Address = 2603:c022:c001:b500:f1d4:5343:e8ce:d6ba
    '';
  };
}

## `opc` is the username from the oracle image. Replace with root if we are booted into nixos.
# nix run --inputs-from . nixpkgs#nixos-anywhere -- \
#   --debug \
#   --flake '.#web01' \
#   opc@141.144.201.31

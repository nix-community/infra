{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.networking.nix-community;
in {
  options = {
    networking.nix-community.ipv6.address = mkOption {
      type = types.str;
    };

    networking.nix-community.ipv6.cidr = mkOption {
      type = types.str;
      default = "64";
    };

    networking.nix-community.ipv6.gateway = mkOption {
      type = types.str;
      default = "fe80::1";
    };
  };

  config = {
    networking.usePredictableInterfaceNames = false;
    networking.dhcpcd.enable = false;
    systemd.network = {
      enable = true;
      networks."ethernet".extraConfig = ''
        [Match]
        Type = ether
        [Network]
        DHCP = ipv4
        Address = ${cfg.ipv6.address}/${cfg.ipv6.cidr}
        Gateway = ${cfg.ipv6.gateway}
      '';
    };
  };
}

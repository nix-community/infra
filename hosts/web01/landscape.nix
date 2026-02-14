{ config, ... }:
{
  virtualisation.quadlet.containers = {
    nixos-landscape = {
      inherit (config.users.users.quadlet) uid;
      containerConfig = {
        AutoUpdate = "registry";
        Image = "ghcr.io/nixlang-wiki/nixos-landscape:latest";
        PublishPort = [ "8082:80" ];
      };
    };
  };

  services.nginx.virtualHosts."landscape.nix-community.org" = {
    locations."/".proxyPass = "http://127.0.0.1:8082";
  };
}

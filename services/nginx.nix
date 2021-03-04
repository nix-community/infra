{ config, lib, pkgs, ... }:

{
  # nginx is being used as the frontend HTTP server for all the services
  # running on the box
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 443 80 ];
}

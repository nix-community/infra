{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  # nginx is being used as the frontend HTTP server for all the services
  # running on the box
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Should we have this?
    #commonHttpConfig = ''
    #  add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload' always;
    #'';

    resolver.addresses =
      if config.networking.nameservers == [ ]
      then [ "1.1.1.1" ]
      else config.networking.nameservers;

    sslDhparam = config.security.dhparams.params.nginx.path;
  };

  security.dhparams = {
    enable = true;
    params.nginx = { };
  };
}

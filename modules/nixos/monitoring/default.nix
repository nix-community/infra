{ config, ... }:
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./matrix-hook.nix
    ./prometheus.nix
    ./telegraf.nix
  ];

  sops.secrets.nginx-basic-auth-file.owner = "nginx";

  services.nginx.virtualHosts."monitoring.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".return = "302 https://nix-community.org/monitoring";
    locations."/alertmanager/" = {
      basicAuthFile = config.sops.secrets.nginx-basic-auth-file.path;
      proxyPass = "http://localhost:9093/";
    };
    locations."/grafana/" = {
      proxyPass = "http://localhost:3000/";
      proxyWebsockets = true;
    };
    locations."/loki/" = {
      basicAuthFile = config.sops.secrets.nginx-basic-auth-file.path;
      proxyPass = "http://localhost:3100/";
      proxyWebsockets = true;
    };
    locations."/prometheus/".proxyPass = "http://localhost:9090/";
  };
}

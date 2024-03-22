{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.roles-prometheus
    ./alert-rules.nix
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
    locations."/prometheus/".proxyPass = "http://localhost:9090/";
  };
}

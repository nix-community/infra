{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.roles-prometheus
    ./alert-rules.nix
    ./matrix-hook.nix
    ./prometheus.nix
    ./telegraf.nix
  ];

  age.secrets.nginx-basic-auth-file = {
    file = "${inputs.self}/secrets/nginx-basic-auth-file.age";
    owner = "nginx";
  };

  services.nginx.virtualHosts."monitoring.nix-community.org" = {
    locations."/".return = "302 https://nix-community.org/monitoring";
    locations."/alertmanager/" = {
      basicAuthFile = config.age.secrets.nginx-basic-auth-file.path;
      proxyPass = "http://localhost:9093/";
    };
    locations."/prometheus/".proxyPass = "http://localhost:9090/";
  };
}

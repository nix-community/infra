{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.roles-prometheus
    ./alert-rules.nix
    ./grafana.nix
    ./matrix-hook.nix
    ./prometheus.nix
    ./telegraf.nix
  ];

  age.secrets.nginx-basic-auth-file = {
    file = "${inputs.self}/secrets/nginx-basic-auth-file.age";
    owner = "nginx";
  };

  services.nginx.virtualHosts."alertmanager.nix-community.org" = {
    locations."/" = {
      basicAuthFile = config.age.secrets.nginx-basic-auth-file.path;
      proxyPass = "http://localhost:9093/";
    };
  };
  services.nginx.virtualHosts."grafana.nix-community.org" = {
    locations."/" = {
      proxyPass = "http://localhost:3000/";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."prometheus.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:9090/";
  };
}

{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.roles-prometheus
    ./alert-rules.nix
    ./alertmanager.nix
    ./grafana.nix
    ./matrix-hook.nix
    ./oauth2-proxy.nix
    ./telegraf.nix
    ./victoriametrics.nix
  ];

  services.nginx.virtualHosts."alertmanager.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:9093/";
  };
  services.nginx.virtualHosts."grafana.nix-community.org" = {
    locations."/" = {
      proxyPass = "http://localhost:3000/";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."victoriametrics.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:8428/";
  };
}

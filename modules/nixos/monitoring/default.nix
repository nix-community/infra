{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.roles-prometheus
    ./alert-rules.nix
    ./matrix-hook.nix
    ./oauth2-proxy.nix
    ./prometheus.nix
    ./telegraf.nix
    ./victoriametrics.nix
  ];

  services.nginx.virtualHosts."alertmanager.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:9093/";
  };
  services.nginx.virtualHosts."prometheus.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:9090/";
  };
  services.nginx.virtualHosts."victoriametrics.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:8428/";
  };
}

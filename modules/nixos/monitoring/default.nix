{
  imports = [
    ./grafana.nix
    ./matrix-hook.nix
    ./prometheus.nix
    ./telegraf.nix
  ];

  services.nginx.virtualHosts."monitoring.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".return = "302 https://nix-community.org/monitoring";
    locations."/alertmanager/".proxyPass = "http://localhost:9093/";
    locations."/grafana/" = {
      proxyPass = "http://localhost:3000/";
      proxyWebsockets = true;
    };
    locations."/prometheus/".proxyPass = "http://localhost:9090/";
  };
}

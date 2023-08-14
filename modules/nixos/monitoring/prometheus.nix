{ pkgs, ... }:
{
  services.prometheus = {
    enable = true;
    ruleFiles = [
      (pkgs.writeText "prometheus-rules.yml" (builtins.toJSON {
        groups = [
          {
            name = "alerting-rules";
            rules = import ./alert-rules.nix { inherit (pkgs) lib; };
          }
        ];
      }))
    ];
    webExternalUrl = "https://prometheus.nix-community.org";
    scrapeConfigs = [
      {
        job_name = "telegraf";
        scrape_interval = "60s";
        metrics_path = "/metrics";
        static_configs = [
          {
            targets = map (host: "${host}:9273")
              [
                "build01.nix-community.org"
                "build02.nix-community.org"
                "build03.nix-community.org"
                "build04.nix-community.org"
                "darwin02.nix-community.org"
                "darwin03.nix-community.org"
                "web01.nix-community.org"
                #"web02.nix-community.org"
                "localhost"
              ];
            labels.org = "nix-community";
          }
        ];
      }
    ];
    alertmanagers = [
      {
        static_configs = [
          {
            targets = [ "localhost:9093" ];
          }
        ];
      }
    ];
  };

  services.nginx.virtualHosts."prometheus.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:9090";
  };

  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.nix-community.org";
    listenAddress = "[::1]";
    configuration = {
      route = {
        receiver = "default";
        routes = [
          {
            group_by = [ "host" ];
            group_wait = "5m";
            group_interval = "5m";
            repeat_interval = "4h";
            receiver = "nix-community";
          }
        ];
      };
      receivers = [
        {
          name = "nix-community";
          webhook_configs = [
            {
              url = "http://localhost:9088/alert";
              max_alerts = 5;
            }
          ];
        }
        {
          name = "default";
        }
      ];
    };
  };

  services.nginx.virtualHosts."alertmanager.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:9093";
  };
}

{
  services.prometheus = {
    enable = true;
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
  };

  services.nginx.virtualHosts."prometheus.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:9090";
  };
}

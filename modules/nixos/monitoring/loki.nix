{
  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:3100/metrics"
  ];

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      analytics.reporting_enabled = false;

      alertmanager_url = "http://localhost:9093";
    };
  };
}

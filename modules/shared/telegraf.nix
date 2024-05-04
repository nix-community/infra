{
  services.telegraf.extraConfig.inputs = {
    prometheus = {
      metric_version = 2;
    };
  };
}

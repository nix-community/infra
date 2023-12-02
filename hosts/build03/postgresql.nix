{
  services.postgresql = {
    enable = true;
    settings = {
      max_connections = "300";
      effective_cache_size = "4GB";
      shared_buffers = "4GB";
    };
  };
}

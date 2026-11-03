{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.nginx
  ];

  services.nginx.eventsConfig = ''
    worker_connections 1024;
  '';

  systemd.services.nginx = {
    serviceConfig.LimitNOFILE = 10 * 1024;
  };
}

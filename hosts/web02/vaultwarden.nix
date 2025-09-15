{ config, ... }:
{
  sops.secrets.vaultwarden-env-file = { };

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    environmentFile = config.sops.secrets.vaultwarden-env-file.path;
    config = {
      DOMAIN = "https://vaultwarden.nix-community.org";
      SIGNUPS_ALLOWED = false;
      ROCKET_LOG = "critical";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.nginx.virtualHosts."vaultwarden.nix-community.org" = {
    locations."/".proxyPass = "http://localhost:8222";
  };
}

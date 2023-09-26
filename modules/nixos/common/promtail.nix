{ config, ... }:
{
  sops.secrets.nginx-basic-auth-password.owner = "promtail";

  services.promtail = {
    enable = true;
    configuration = {
      clients = [
        {
          basic_auth.username = "nginx@nix-community";
          basic_auth.password_file = config.sops.secrets.nginx-basic-auth-password.path;
          url = "https://monitoring.nix-community.org/loki/loki/api/v1/push";
        }
      ];
    };
  };
}

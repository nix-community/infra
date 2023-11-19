{ config, ... }:
{
  systemd.services.grafana.after = [ "prometheus.service" ];

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;
      analytics.feedback_links_enabled = false;

      "auth.anonymous".enabled = true;

      # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/github/
      "auth.github" = {
        enabled = true;
        client_id = "ea6aa36488df8b2dede6";
        client_secret = "$__file{${config.sops.secrets.grafana-client-secret.path}}";
        auth_url = "https://github.com/login/oauth/authorize";
        token_url = "https://github.com/login/oauth/access_token";
        api_url = "https://api.github.com/user";
        allow_sign_up = true;
        auto_login = false;
        allowed_organizations = [ "nix-community" ];
        role_attribute_strict = true;
        allow_assign_grafana_admin = true;
        role_attribute_path = "contains(groups[*], '@nix-community/admin') && 'GrafanaAdmin' || 'Editor'";
      };

      server = {
        root_url = "https://monitoring.nix-community.org/grafana/";
        domain = "monitoring.nix-community.org";
        enforce_domain = true;
        enable_gzip = true;
      };

      database = {
        type = "postgres";
        name = "grafana";
        host = "/run/postgresql";
        user = "grafana";
      };

      security.admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
    };

    provision.datasources.settings.datasources = [
      {
        name = "prometheus";
        type = "prometheus";
        isDefault = true;
        url = "http://localhost:9090";
      }
    ];
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:3000/metrics"
  ];

  sops.secrets.grafana-admin-password.owner = "grafana";
  sops.secrets.grafana-client-secret.owner = "grafana";

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" ];
    ensureUsers = [{
      name = "grafana";
      ensureDBOwnership = true;
    }];
  };
}

{ config, pkgs, ... }:
{
  sops.secrets.grafana-client-secret = {
    owner = "grafana";
  };

  sops.secrets.grafana-secret-key = {
    owner = "grafana";
  };

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
        role_attribute_path = "contains(groups[*], '@nix-community/admin') && 'GrafanaAdmin' || 'None'";
      };

      server = {
        root_url = "https://grafana.nix-community.org/";
        domain = "grafana.nix-community.org";
        enforce_domain = true;
        enable_gzip = true;
      };

      database = {
        type = "postgres";
        name = "grafana";
        host = "/run/postgresql";
        user = "grafana";
      };

      security = {
        disable_initial_admin_creation = true;
        secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
      };
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-metrics-datasource
    ];

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "victoriametrics";
          type = "victoriametrics-metrics-datasource";
          url = "http://localhost:8428";
          isDefault = true;
          jsonData.vmuiUrl = "https://victoriametrics.nix-community.org/vmui/";
        }
      ];
    };
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:3000/metrics"
  ];

  services.postgresql = {
    ensureDatabases = [ "grafana" ];
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
  };
}

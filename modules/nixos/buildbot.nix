{ config, inputs, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.nginx.virtualHosts."buildbot.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
  };

  services.telegraf.extraConfig.inputs.prometheus.urls = [
    "http://localhost:8011/metrics"
  ];

  sops.secrets.buildbot-github-oauth-secret = { };
  sops.secrets.buildbot-github-token = { };
  sops.secrets.buildbot-github-webhook-secret = { };
  sops.secrets.buildbot-nix-workers = { };

  services.buildbot-nix.master = {
    enable = true;
    buildSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    domain = "buildbot.nix-community.org";
    prometheusExporterPort = 8011;
    evalMaxMemorySize = "4096";
    evalWorkerCount = 8;
    workersFile = config.sops.secrets.buildbot-nix-workers.path;
    github = {
      tokenFile = config.sops.secrets.buildbot-github-token.path;
      webhookSecretFile = config.sops.secrets.buildbot-github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.buildbot-github-oauth-secret.path;
      oauthId = "9bbd3e8bbfebb197d2ca";
      user = "nix-community-buildbot";
      admins = [ "adisbladis" "Mic92" "ryantm" "zimbatm" "zowoq" ];
      topic = "nix-community-buildbot";
    };
  };

  systemd.targets.multi-user.unitConfig.Upholds = [
    "buildbot-master.service"
    "buildbot-worker.service"
  ];

  sops.secrets.cachix-auth-token = { };
  sops.secrets.cachix-name = { };

  systemd.services.buildbot-master.serviceConfig.LoadCredential = [
    "cachix-auth-token:${config.sops.secrets.cachix-auth-token.path}"
    "cachix-name:${config.sops.secrets.cachix-name.path}"
  ];

  sops.secrets.buildbot-nix-worker-password = { };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.buildbot-nix-worker-password.path;
  };
}

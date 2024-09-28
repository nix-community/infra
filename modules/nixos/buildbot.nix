{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.nginx.virtualHosts."buildbot.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
  };

  sops.secrets.buildbot-github-oauth-secret = { };
  sops.secrets.buildbot-github-app-secret-key = { };
  sops.secrets.buildbot-github-webhook-secret = { };
  sops.secrets.buildbot-nix-workers = { };
  sops.secrets.cachix-auth-token = { };

  services.buildbot-nix.master = {
    enable = true;
    admins = [
      "adisbladis"
      "ryantm"
      "zimbatm"
      "zowoq"
    ];
    buildSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    domain = "buildbot.nix-community.org";
    outputsPath = "/var/www/buildbot/nix-outputs/";
    evalMaxMemorySize = 4096;
    evalWorkerCount = 32;
    jobReportLimit = 0;
    workersFile = config.sops.secrets.buildbot-nix-workers.path;
    cachix = {
      enable = true;
      name = "nix-community";
      auth.authToken.file = config.sops.secrets.cachix-auth-token.path;
    };
    github = {
      authType.app = {
        id = 920387;
        secretKeyFile = config.sops.secrets.buildbot-github-app-secret-key.path;
      };
      webhookSecretFile = config.sops.secrets.buildbot-github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.buildbot-github-oauth-secret.path;
      oauthId = "Iv23liN9rjd1Bm3bvYKZ";
      topic = "nix-community-buildbot";
    };
  };

  services.buildbot-master = {
    title = "Nix Community";
    titleUrl = "https://nix-community.org/";
  };

  sops.secrets.buildbot-nix-worker-password = { };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.buildbot-nix-worker-password.path;
  };
}

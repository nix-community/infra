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

  services.nginx.virtualHosts."buildbot.nix-community.org" = { };

  age.secrets.buildbot-github-oauth-secret = {
    file = "${inputs.self}/secrets/buildbot-github-oauth-secret.age";
  };
  age.secrets.buildbot-github-app-secret-key = {
    file = "${inputs.self}/secrets/buildbot-github-app-secret-key.age";
  };
  age.secrets.buildbot-github-webhook-secret = {
    file = "${inputs.self}/secrets/buildbot-github-webhook-secret.age";
  };
  age.secrets.buildbot-nix-workers = {
    file = "${inputs.self}/secrets/buildbot-nix-workers.age";
  };
  age.secrets.cachix-auth-token = {
    file = "${inputs.self}/secrets/cachix-auth-token.age";
  };

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
    workersFile = config.age.secrets.buildbot-nix-workers.path;
    cachix = {
      enable = true;
      name = "nix-community";
      auth.authToken.file = config.age.secrets.cachix-auth-token.path;
    };
    github = {
      authType.app = {
        id = 920387;
        secretKeyFile = config.age.secrets.buildbot-github-app-secret-key.path;
      };
      webhookSecretFile = config.age.secrets.buildbot-github-webhook-secret.path;
      oauthSecretFile = config.age.secrets.buildbot-github-oauth-secret.path;
      oauthId = "Iv23liN9rjd1Bm3bvYKZ";
      topic = "nix-community-buildbot";
    };
  };

  services.buildbot-master = {
    title = "Nix Community";
    titleUrl = "https://nix-community.org/";
  };

  age.secrets.buildbot-nix-worker-password = {
    file = "${inputs.self}/secrets/buildbot-nix-worker-password.age";
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.age.secrets.buildbot-nix-worker-password.path;
  };
}

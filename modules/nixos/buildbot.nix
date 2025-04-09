{
  config,
  inputs,
  ...
}:
let
  buildSystems =
    [
      config.nixpkgs.hostPlatform.system
    ]
    ++ config.nix.settings.extra-platforms
    ++ builtins.concatLists (map (host: host.systems) config.nix.buildMachines);

  WORKER_COUNT = toString config.nix.settings.max-jobs;
in
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.nginx.virtualHosts."buildbot.nix-community.org" = { };

  sops.secrets.buildbot-github-oauth-secret = { };
  sops.secrets.buildbot-github-app-secret-key = { };
  sops.secrets.buildbot-github-webhook-secret = { };
  sops.secrets.buildbot-nix-worker-password = { };
  sops.secrets.cachix-auth-token = { };

  sops.templates.buildbot-nix-workers.content = ''
    [{
      "name": "${config.networking.hostName}",
      "pass": "${config.sops.placeholder.buildbot-nix-worker-password}",
      "cores": ${WORKER_COUNT}
    }]
  '';

  services.buildbot-nix.master = {
    enable = true;
    admins = [
      "adisbladis"
      "ryantm"
      "zimbatm"
      "zowoq"
    ];
    inherit buildSystems;
    domain = "buildbot.nix-community.org";
    outputsPath = "/var/www/buildbot/nix-outputs/";
    evalMaxMemorySize = 4096;
    evalWorkerCount = 32;
    jobReportLimit = 0;
    workersFile = config.sops.templates.buildbot-nix-workers.path;
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

  sops.secrets.buildbot-effects-nix-community-infra = { };

  services.buildbot-nix.master.effects.perRepoSecretFiles = {
    "github:nix-community/infra" = config.sops.secrets.buildbot-effects-nix-community-infra.path;
  };

  services.buildbot-master = {
    title = "Nix Community";
    titleUrl = "https://nix-community.org/";
  };

  systemd.services.buildbot-worker.environment = { inherit WORKER_COUNT; };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.buildbot-nix-worker-password.path;
  };
}

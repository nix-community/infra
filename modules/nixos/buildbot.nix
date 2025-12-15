{
  config,
  inputs,
  pkgs,
  ...
}:
let
  repoAllowlist = [
    # keep-sorted start case=no
    "nix-community/authentik-nix"
    "nix-community/bun2nix"
    "nix-community/dream2nix"
    "nix-community/ethereum.nix"
    "nix-community/fenix"
    "nix-community/home-manager"
    "nix-community/infra"
    "nix-community/lanzaboote"
    "nix-community/neovim-nightly-overlay"
    "nix-community/nh"
    "nix-community/nix-direnv"
    "nix-community/nix-eval-jobs"
    "nix-community/nix-index"
    "nix-community/nix4nvchad"
    "nix-community/NixNG"
    "nix-community/nixos-apple-silicon"
    "nix-community/nixos-facter"
    "nix-community/nixos-facter-modules"
    "nix-community/nixos-generators"
    "nix-community/nixos-images"
    "nix-community/nixpkgs-update"
    "nix-community/nixpkgs-xr"
    "nix-community/nixvim"
    "nix-community/srvos"
    "nix-community/stylix"
    # keep-sorted end
  ];

  buildSystems = [
    pkgs.stdenv.hostPlatform.system
  ]
  ++ builtins.concatLists (map (host: host.systems) config.nix.buildMachines);

  WORKER_COUNT = config.nix.settings.max-jobs;
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
      "cores": ${toString WORKER_COUNT}
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
    showTrace = true;
    evalMaxMemorySize = 4096;
    evalWorkerCount = 32;
    cacheFailedBuilds = false;
    workersFile = config.sops.templates.buildbot-nix-workers.path;
    cachix = {
      enable = true;
      name = "nix-community";
      auth.authToken.file = config.sops.secrets.cachix-auth-token.path;
    };
    github = {
      appId = 920387;
      appSecretKeyFile = config.sops.secrets.buildbot-github-app-secret-key.path;
      webhookSecretFile = config.sops.secrets.buildbot-github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.buildbot-github-oauth-secret.path;
      oauthId = "Iv23liN9rjd1Bm3bvYKZ";
      topic = null;
      inherit repoAllowlist;
    };
  };

  # reset github project cache when starting service
  systemd.services.buildbot-master.preStart = pkgs.lib.mkAfter ''
    rm -f /var/lib/buildbot/github-*.json
  '';

  sops.secrets.buildbot-effects-nix-community-infra = { };

  services.buildbot-nix.master.effects.perRepoSecretFiles = {
    "github:nix-community/infra" = config.sops.secrets.buildbot-effects-nix-community-infra.path;
  };

  services.buildbot-master = {
    title = "Nix Community";
    titleUrl = "https://nix-community.org/";
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.buildbot-nix-worker-password.path;
    workers = WORKER_COUNT;
  };
}

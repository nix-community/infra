{
  config,
  inputs,
  pkgs,
  ...
}:
let
  repoAllowlist = [
    # keep-sorted start case=no
    "nix-community/home-manager"
    "nix-community/infra"
    "nix-community/neovim-nightly-overlay"
    "nix-community/nix-direnv"
    "nix-community/nixos-facter"
    "nix-community/nixos-images"
    "nix-community/nixpkgs-update"
    "nix-community/nixvim"
    "nix-community/srvos"
    "NixOS/home-manager"
    # keep-sorted end
  ];

  buildSystems = [
    pkgs.stdenv.hostPlatform.system
  ]
  ++ config.nix.settings.extra-platforms
  ++ builtins.concatLists (map (host: host.systems) config.nix.buildMachines);
in
{
  imports = [
    inputs.nixbot.nixosModules.nixbot
  ];

  services.nixbot.pullBased = {
    pollInterval = 3600;
    repositories = {
      "nix-darwin" = {
        url = "https://github.com/nix-darwin/nix-darwin.git";
        defaultBranch = "master";
      };
    };
  };

  services.nginx.virtualHosts."nixbot.nix-community.org" = { };

  sops.secrets.nixbot-gitlab-token = { };
  sops.secrets.nixbot-github-oauth-secret = { };
  sops.secrets.nixbot-github-app-secret-key = { };
  sops.secrets.nixbot-github-webhook-secret = { };
  sops.secrets.cachix-auth-token = { };

  services.nixbot = {
    enable = true;
    admins = [
      "github:adisbladis"
      "github:mdaniels5757"
      "github:mweinelt"
      "github:ryantm"
      "github:zimbatm"
      "github:zowoq"
    ];
    inherit buildSystems;
    domain = "nixbot.nix-community.org";
    outputsPath = "/var/www/nixbot/nix-outputs/";
    showTrace = true;
    evalMaxMemorySize = 4096;
    evalWorkerCount = 32;
    cacheFailedBuilds = false;
    cachix = {
      enable = true;
      name = "nix-community";
      auth.authToken.file = config.sops.secrets.cachix-auth-token.path;
    };
    github = {
      enable = true;
      appId = 4016365;
      appSecretKeyFile = config.sops.secrets.nixbot-github-app-secret-key.path;
      webhookSecretFile = config.sops.secrets.nixbot-github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.nixbot-github-oauth-secret.path;
      oauthId = "Iv23li2s1vLGoe5sUdwL";
      topic = null;
      inherit repoAllowlist;
    };
    gitlab = {
      enable = true;
      # https://github.com/nix-community-buildbot -> https://gitlab.com/nix-community-buildbot
      tokenFile = config.sops.secrets.nixbot-gitlab-token.path; # token expires 2027-06-13
      topic = null;
      repoAllowlist = [
        "simple-nixos-mailserver/nixos-mailserver"
      ];
    };
  };

  sops.secrets.nixbot-effects-nix-community-infra = { };

  services.nixbot.effects.perRepoSecretFiles = {
    "github:nix-community/infra" = config.sops.secrets.nixbot-effects-nix-community-infra.path;
  };
}

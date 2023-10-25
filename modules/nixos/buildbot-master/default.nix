{ config, inputs, lib, ... }:
let
  buildbotSecrets.sopsFile = ./secrets.yaml;
in
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
  ];

  services.nginx.virtualHosts."buildbot.nix-community.org" = {
    enableACME = true;
    forceSSL = true;
  };

  sops.secrets.github-oauth-secret = buildbotSecrets;
  sops.secrets.github-token = buildbotSecrets;
  sops.secrets.github-webhook-secret = buildbotSecrets;
  sops.secrets.nix-workers = buildbotSecrets;

  services.buildbot-nix.master = {
    enable = true;
    buildSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    domain = "buildbot.nix-community.org";
    workersFile = config.sops.secrets.nix-workers.path;
    github = {
      tokenFile = config.sops.secrets.github-token.path;
      webhookSecretFile = config.sops.secrets.github-webhook-secret.path;
      oauthSecretFile = config.sops.secrets.github-oauth-secret.path;
      oauthId = "9bbd3e8bbfebb197d2ca";
      user = "nix-community-buildbot";
      admins = [ "adisbladis" "Mic92" "ryantm" "zimbatm" "zowoq" ];
      topic = "nix-community-buildbot";
    };
  };

  sops.secrets.cachix-auth-token = buildbotSecrets;
  sops.secrets.cachix-name = buildbotSecrets;

  systemd.services.buildbot-master.serviceConfig.LoadCredential = [
    "cachix-auth-token:${config.sops.secrets.cachix-auth-token.path}"
    "cachix-name:${config.sops.secrets.cachix-name.path}"
  ];

  services.buildbot-master.home = "/var/lib/buildbot";
  users.users.buildbot = {
    isNormalUser = lib.mkForce false;
    isSystemUser = true;
  };
}

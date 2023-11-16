{ config, inputs, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  sops.secrets.nix-worker-password.sopsFile = ./secrets.yaml;

  services.buildbot-nix.worker = {
    enable = true;
    masterUrl = "tcp:host=buildbot.nix-community.org:port=9989";
    workerPasswordFile = config.sops.secrets.nix-worker-password.path;
  };
}

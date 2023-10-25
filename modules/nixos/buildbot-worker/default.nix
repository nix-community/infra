{ config, inputs, ... }:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  sops.secrets.nix-worker-password.sopsFile = ./secrets.yaml;

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = config.sops.secrets.nix-worker-password.path;
  };
}

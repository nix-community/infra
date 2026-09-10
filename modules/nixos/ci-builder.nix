{ config, inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/nixos-modules/builder-module.nix")
  ];

  sops.secrets.hydra-queue-builder-token.owner = "hydra-queue-builder";

  services.hydra-queue-builder-dev = {
    enable = true;
    authorizationFile = config.sops.secrets.hydra-queue-builder-token.path;
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
  };
}

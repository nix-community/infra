{ config, inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    inputs.hydra.nixosModules.builder
  ];

  sops.secrets.hydra-queue-builder-token.owner = "hydra-queue-builder";

  services.hydra-queue-builder-dev = {
    enable = true;
    authorizationFile = config.sops.secrets.hydra-queue-builder-token.path;
    queueRunnerAddr = "https://queue-runner.hydra.nix-community.org";
  };
}

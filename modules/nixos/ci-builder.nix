{ inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/nixos-modules/builder-module.nix")
  ];

  services.hydra-queue-builder-dev.settings = {
    buildCores = 4;
    maxJobs = 10;
  };
}

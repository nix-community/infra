{ inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/darwin-modules/builder-module.nix")
  ];

  services.hydra-queue-builder-dev.settings = {
    buildCores = 2;
    maxJobs = 4;
  };

  users = {
    users.hydra-queue-builder.uid = 6535;
    groups.hydra.gid = 6535;
  };
}

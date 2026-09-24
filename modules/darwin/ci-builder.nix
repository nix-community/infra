{ inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/darwin-modules/builder-module.nix")
  ];

  users = {
    users.hydra-queue-builder.uid = 6535;
    groups.hydra.gid = 6535;
  };
}

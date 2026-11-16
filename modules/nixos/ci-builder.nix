{ inputs, ... }:
{
  disabledModules = [
    "services/continuous-integration/hydra/builder.nix"
  ];

  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/nixos-modules/builder-module.nix")
  ];
}

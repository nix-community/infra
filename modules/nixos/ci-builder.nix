{ inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    (import "${inputs.hydra}/nixos-modules/builder-module.nix")
  ];
}

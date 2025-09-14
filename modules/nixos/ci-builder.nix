{ inputs, ... }:
{
  imports = [
    ../shared/ci-builder.nix
    "${inputs.self}/modules/queue-runner/hydra-queue-builder-v2.nix"
  ];
}

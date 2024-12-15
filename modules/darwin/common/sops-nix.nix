{ inputs, ... }:
{
  imports = [
    ../../shared/sops-nix.nix
    inputs.sops-nix.darwinModules.sops
  ];
}

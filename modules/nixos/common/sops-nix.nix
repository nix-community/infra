{ inputs, ... }:
{
  imports = [
    ../../shared/sops-nix.nix
    inputs.sops-nix.nixosModules.sops
  ];
}

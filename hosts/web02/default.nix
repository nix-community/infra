{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
  ];

  networking.useDHCP = true;
}

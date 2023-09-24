{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    ./postgresql.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
  ];

  networking.useDHCP = true;
}

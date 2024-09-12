{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.monitoring
    inputs.srvos.nixosModules.mixins-nginx
  ];

  networking.useDHCP = true;
}

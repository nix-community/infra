{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.common
    inputs.self.nixosModules.monitoring
    inputs.srvos.nixosModules.mixins-nginx
    inputs.self.nixosModules.cachix-deploy
  ];

  networking.hostName = "web02";

  networking.useDHCP = true;
}

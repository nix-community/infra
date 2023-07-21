{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.common
  ];

  networking.hostName = "web02";

  networking.useDHCP = true;
}

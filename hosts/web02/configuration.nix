{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.common
    ./gandi.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
  ];

  networking.hostName = "web02";

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.useDHCP = true;
}

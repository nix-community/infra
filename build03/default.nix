{ self, ... }:
{
  flake.nixosConfiguration.build03 = self.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./configuration.nix ];
  };
}

{ self, ... }:
{
  flake.nixosConfigurations.build01 = self.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./configuration.nix ];
  };
}

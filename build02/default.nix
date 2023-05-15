{ self, ... }:
{
  flake.nixosConfigurations.build02 = self.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./configuration.nix ];
  };
}


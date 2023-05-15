{ self, ... }:
{
  flake.nixosConfigurations.build04 = self.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [ ./configuration.nix ];
  };
}

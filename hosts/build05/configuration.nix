{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.common
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.remote-builder-user
  ];

  # disable kvm/nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "build05";
}

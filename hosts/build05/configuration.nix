{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.common
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.remote-builder-user
    inputs.self.nixosModules.disko-single-disk-zfs
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
  ];

  # disable kvm/nixos-tests
  nix.settings.system-features = [ "big-parallel" ];

  networking.hostName = "build05";

  networking.hostId = "8425e349";

  system.stateVersion = "23.05";
}

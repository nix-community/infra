{ inputs, ... }:
{
  imports = [
    # no hercules CI, doesn't support mandatoryFeatures
    ./nvidia.nix
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.remote-builder
    inputs.srvos.nixosModules.hardware-hetzner-online-intel
  ];

  nix.settings.max-jobs = 14;

  systemd.network.networks."10-uplink".networkConfig.Address = "1.2.3.4";

  system.stateVersion = "24.11";
}

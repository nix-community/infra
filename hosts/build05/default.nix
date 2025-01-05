{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.community-builder
    inputs.self.nixosModules.disko-zfs
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
  ];

  nix.settings.max-jobs = 80;

  nixpkgs.hostPlatform.gcc.arch = "armv8-a";

  system.stateVersion = "23.11";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:5066::1";
}

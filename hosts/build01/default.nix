{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.community-builder
    inputs.self.nixosModules.disko-zfs
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  systemd.watchdog.runtimeTime = "30s";

  nix.settings.max-jobs = 96;

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];
  boot.binfmt.preferStaticEmulators = true;

  systemd.network.networks."10-uplink".networkConfig.Address = "?";

  system.stateVersion = "23.11";
}

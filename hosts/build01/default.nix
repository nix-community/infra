{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.cgroups
    inputs.self.nixosModules.community-builder
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  nix.settings.max-jobs = 24;

  nixpkgs.hostPlatform.gcc.arch = "znver2";

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];
  boot.binfmt.preferStaticEmulators = true;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:2946::1/64";

  system.stateVersion = "23.11";
}

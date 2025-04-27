{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.clang-lto-kernel
    inputs.self.nixosModules.community-builder
    inputs.self.nixosModules.disko-zfs
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  nixCommunity.threads = 24;

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];
  boot.binfmt.preferStaticEmulators = true;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:2946::1/64";

  system.stateVersion = "23.11";
}

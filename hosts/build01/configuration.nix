{ config, inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.community-builder
  ];

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  networking.hostName = "build01";

  networking.domains.baseDomains."${config.networking.domain}" = {
    a.data = "135.181.218.169";
    aaaa.data = "2a01:4f9:3a:3b16::1";
  };

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  system.stateVersion = "23.11";
}

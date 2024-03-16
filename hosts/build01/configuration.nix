{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.disko-raid
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.community-builder
  ];
  nixCommunity.disko.raidLevel = 0; # more disk space, we don't have state to restore anyway

  services.comin.enable = true;
  system.autoUpgrade.enable = false;

  # Emulate riscv64 until we have proper builders
  boot.binfmt.emulatedSystems = [ "riscv64-linux" ];

  networking.hostName = "build01";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3a:3b16::1/64";

  system.stateVersion = "23.11";
}

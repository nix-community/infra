{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.common
    inputs.self.nixosModules.buildbot
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.watch-store
    inputs.self.nixosModules.remote-workers

    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nur-update
    ./disko.nix
    ./postgresql.nix
  ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:2946::1/64";

  networking.hostName = "build03";
  networking.hostId = "8daf74c0";

  system.stateVersion = "23.11";
}

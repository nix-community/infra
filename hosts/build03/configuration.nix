{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.common
    inputs.self.nixosModules.nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.buildbot
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.watch-store
    ./builders.nix

    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nur-update
    ./postgresql.nix
  ];

  networking.hostName = "build03";

  nixpkgs.hostPlatform = "x86_64-linux";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}

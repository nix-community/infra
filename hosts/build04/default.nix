{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.remote-builder
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  nix.settings.max-jobs = 80;

  # error: failed to start SSH connection
  # https://github.com/nix-community/infra/issues/1416
  services.openssh.settings.MaxStartups = 100;

  system.stateVersion = "23.11";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:3962::2";
}

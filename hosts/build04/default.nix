{ inputs, ... }:
{
  imports = [
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs
    inputs.self.nixosModules.remote-builder
    inputs.srvos.nixosModules.hardware-hetzner-online-arm
  ];

  nix.settings.max-jobs = 80;

  # error: failed to start SSH connection
  # https://github.com/nix-community/infra/issues/1416
  services.openssh.settings.MaxStartups = 100;

  # set in srvos, remove when reinstalling
  networking.hostId = "deadbeef";

  system.stateVersion = "23.11";

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3051:3962::2";
}

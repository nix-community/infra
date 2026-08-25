{ inputs, lib, ... }:
{
  imports = [
    ./gandi.nix
    ./landscape.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nur-update
    inputs.self.nixosModules.quadlet
    inputs.self.nixosModules.rfc39
  ];

  services.userborn.enable = lib.mkForce true;

  networking.useDHCP = true;

  systemd.services.openstack-init.enableStrictShellChecks = false;
}

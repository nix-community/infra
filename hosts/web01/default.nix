{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    ./landscape.nix
    ./postgresql.nix
    ./postgresql-tf.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nur-update
    inputs.self.nixosModules.quadlet
    inputs.self.nixosModules.rfc39
  ];

  networking.useDHCP = true;

  systemd.services.openstack-init.enableStrictShellChecks = false;
}

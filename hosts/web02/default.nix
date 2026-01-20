{ inputs, ... }:
{
  imports = [
    ./gandi.nix
    ./postgresql.nix
    ./postgresql-tf.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.nginx
  ];

  networking.useDHCP = true;

  systemd.services.openstack-init.enableStrictShellChecks = false;
}

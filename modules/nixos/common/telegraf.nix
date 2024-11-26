{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.mixins-telegraf
    ../../shared/telegraf.nix
  ];

  #  error: creating directory '/var/empty/.cache/nix': Operation not permitted
  users.users.telegraf = {
    home = "/var/lib/telegraf";
    createHome = true;
  };

  networking.firewall.allowedTCPPorts = [ 9273 ];
}

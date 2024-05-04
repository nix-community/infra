{ inputs, ... }:
{
  imports = [
    inputs.srvos.nixosModules.mixins-telegraf
    ../../shared/telegraf.nix
  ];

  networking.firewall.allowedTCPPorts = [ 9273 ];
}

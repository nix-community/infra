{ config, inputs, ... }:
{
  imports = [
    inputs.nixos-dns.nixosModules.dns
  ];

  networking.domains = {
    enable = true;
    subDomains."${config.networking.fqdn}" = { };
  };
}

{ config, inputs, ... }:
{
  imports = [
    ./gandi.nix
    inputs.self.nixosModules.common
    inputs.self.nixosModules.monitoring
    inputs.srvos.nixosModules.mixins-nginx
  ];

  networking.hostName = "web02";

  networking.domains.baseDomains."${config.networking.domain}" = {
    a.data = "46.226.105.188";
    aaaa.data = "2001:4b98:dc0:43:f816:3eff:fe99:9fca";
  };

  networking.useDHCP = true;

  # enabled by default for stateVersion < 23.11
  boot.swraid.enable = false;
}

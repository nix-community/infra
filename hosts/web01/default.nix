{ inputs, ... }:
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

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.useDHCP = true;

  systemd.services.openstack-init.enableStrictShellChecks = false;
}

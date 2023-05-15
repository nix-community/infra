{ inputs, pkgs, ... }:
{
  imports = [
    ./auto-upgrade.nix
    ./nix-daemon.nix
    ./security.nix
    ./sops-nix.nix
    ./users.nix
    inputs.sops-nix.nixosModules.sops
    inputs.srvos.nixosModules.mixins-telegraf
    inputs.srvos.nixosModules.server
  ];

  networking.firewall.allowedTCPPorts = [ 9273 ];

  srvos.flake = inputs.self;

  zramSwap.enable = true;

  # https://github.com/hercules-ci/hercules-ci-agent/issues/514
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  # Without configuration this unit will fail...
  # Just disable it since we are using telegraf to monitor raid health.
  systemd.services.mdmonitor.enable = false;

  networking.domain = "nix-community.org";
}

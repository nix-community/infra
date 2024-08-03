{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./comin.nix
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    ./reboot.nix
    ./security.nix
    ./sops-nix.nix
    ./telegraf.nix
    ./users.nix
    inputs.sops-nix.nixosModules.sops
    inputs.agenix.nixosModules.age
    inputs.srvos.nixosModules.server
    inputs.nix-topology.nixosModules.default
  ];

  # Hard-link duplicated files
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = false;

  # users in trusted group are trusted by the nix-daemon
  nix.settings.trusted-users = [ "@trusted" ];

  users.groups.trusted = { };

  # Sometimes it fails if a store path is still in use.
  # This should fix intermediate issues.
  systemd.services.nix-gc.serviceConfig = {
    Restart = "on-failure";
  };

  boot.kernelPackages = pkgs.lib.mkIf (
    !config.boot.supportedFilesystems.zfs or false
  ) pkgs.linuxPackages_latest;

  zramSwap.enable = true;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  # Without configuration this unit will fail...
  # Just disable it since we are using telegraf to monitor raid health.
  systemd.services.mdmonitor.enable = false;

  networking.domain = "nix-community.org";
}

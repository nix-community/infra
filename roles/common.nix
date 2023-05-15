{
  imports = [
    ./auto-upgrade.nix
    ./nix-daemon.nix
    ./security.nix
    ./sops-nix.nix
    ./users.nix
  ];

  zramSwap.enable = true;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  # Without configuration this unit will fail...
  # Just disable it since we are using telegraf to monitor raid health.
  systemd.services.mdmonitor.enable = false;

  networking.domain = "nix-community.org";
}

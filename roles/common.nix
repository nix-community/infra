{ lib, config, ... }:

{
  imports = [
    ./auto-upgrade.nix
    ./nix-daemon.nix
    ./security.nix
    ./sops-nix.nix
    ./users.nix
  ];

  # Nicer interactive shell
  programs.fish.enable = true;
  # And for the zsh peeps
  programs.zsh.enable = true;

  zramSwap.enable = true;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  # Without configuration this unit will fail...
  # Just disable it since we are using telegraf to monitor raid health.
  systemd.services.mdmonitor.enable = false;

  # speed-up evaluation & save disk space by disabling manpages
  documentation.enable = false;

  networking.domain = "nix-community.org";

  # HACK: NixOS does not let us using a hostname that has the domain part included include domain part in hostname
  boot.kernel.sysctl."kernel.hostname" = config.networking.fqdn;

  # don't override host set by sysctl
  system.activationScripts.hostname = lib.mkForce "";
  system.activationScripts.domain = lib.mkForce "";
}

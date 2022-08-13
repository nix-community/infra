{ pkgs, lib, config, ... }:

{

  imports = [
    ./nix-daemon.nix
    ./security.nix
    ./sshd.nix
    ./telegraf
    ./users.nix
    ./zfs.nix
    ./sops-nix.nix
    ./auto-upgrade.nix
  ];

  environment.systemPackages = [
    # for quick activity overview
    pkgs.htop
  ];

  # Nicer interactive shell
  programs.fish.enable = true;
  # And for the zsh peeps
  programs.zsh.enable = true;

  # Entropy gathering daemon
  services.haveged.enable = true;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  # Without configuration this unit will fail...
  # Just disable it since we are using telegraf to monitor raid health.
  systemd.services.mdmonitor.enable = false;

  # enable "sar" system activity collection
  services.sysstat.enable = true;

  # Make debugging failed units easier
  systemd.extraConfig = ''
    DefaultStandardOutput=journal
    DefaultStandardError=journal
  '';

  # The nix-community is global :)
  time.timeZone = "UTC";

  # speed-up evaluation & save disk space by disabling manpages
  documentation.enable = false;

  networking.domain = "nix-community.org";

  # HACK: NixOS does not let us using a hostname that has the domain part included include domain part in hostname
  boot.kernel.sysctl."kernel.hostname" = config.networking.fqdn;

  # don't override host set by sysctl
  system.activationScripts.hostname = lib.mkForce "";
  system.activationScripts.domain = lib.mkForce "";
}

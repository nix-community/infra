{ pkgs, lib, config, ... }:

{

  imports = [
    ./security.nix
    ../services/telegraf
    ./zfs.nix
  ];

  environment.systemPackages = [
    # for quick activity overview
    pkgs.htop
    # for users with TERM=xterm-termite
    pkgs.termite.terminfo
  ];

  # Nicer interactive shell
  programs.fish.enable = true;
  # And for the zsh peeps
  programs.zsh.enable = true;

  # Entropy gathering daemon
  services.haveged.enable = true;

  nix =
    let asGB = size: toString (size * 1024 * 1024); in
    {
      binaryCachePublicKeys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      binaryCaches = [
        "https://nix-community.cachix.org"
      ];

      extraOptions = ''
        # auto-free the /nix/store
        min-free = ${asGB 10}
        max-free = ${asGB 200}

        # avoid copying unecessary stuff over SSH
        builders-use-substitutes = true

        # allow flakes
        experimental-features = nix-command flakes
      '';
      # Hard-link duplicated files
      autoOptimiseStore = true;

      # Add support for flakes
      package = pkgs.nixUnstable;
    };

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

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

  # No mutable users
  users.mutableUsers = false;

  # Assign keys from all users in wheel group
  # This is only done because nixops cant be deployed from any other account
  users.extraUsers.root.openssh.authorizedKeys.keys = lib.unique (
    lib.flatten (
      builtins.map (u: u.openssh.authorizedKeys.keys)
        (
          lib.attrValues (
            lib.filterAttrs (_: u: lib.elem "wheel" u.extraGroups)
              config.users.extraUsers
          )
        )
    )
  );


}

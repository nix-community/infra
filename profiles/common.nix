{ pkgs, lib, config, ... }:

{

  imports = [ ./security.nix ];

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

  nix = let
    asGB = size: toString (size * 1024 * 1024);
  in {
    extraOptions = ''
      # auto-free the /nix/store
      min-free = ${asGB 10}
      max-free = ${asGB 200}

      # avoid copying unecessary stuff over SSH
      builders-use-substitutes = true
    '';
    # Hard-link duplicated files
    autoOptimiseStore = true;
  };

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
  ];

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
  users.extraUsers.root.openssh.authorizedKeys.keys = lib.unique (lib.flatten (
    builtins.map (u: u.openssh.authorizedKeys.keys)
      (lib.attrValues (lib.filterAttrs (_: u: lib.elem "wheel" u.extraGroups)
        config.users.extraUsers))));


}

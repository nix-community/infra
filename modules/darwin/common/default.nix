{ inputs, pkgs, ... }:
let
  authorizedKeys = {
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPVjRBomWFJNNkZb0g5ymLmc3pdRddIScitmJ9yC+ap" # deployment
    ];
    keyFiles = pkgs.lib.filesystem.listFilesRecursive "${toString inputs.self}/users/keys";
  };
in
{
  imports = [
    ./apfs-cleanup.nix
    ./optimise.nix
    ./reboot.nix
    ./telegraf.nix
    ./upgrade-diff.nix
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    inputs.agenix.darwinModules.age
  ];

  # TODO: refactor this to share /users with nixos
  users.users = {
    customer.openssh = {
      inherit authorizedKeys;
    };
  };

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  documentation.enable = false;

  programs.info.enable = false;

  nix.settings.trusted-users = [ "@admin" ];

  # shouldn't need to set this for a nix multi-user install
  nix.gc.user = "root";

  # srvos
  nix.settings.builders-use-substitutes = true;

  # srvos
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [ htop ];

  system.includeUninstaller = false;

  # disable application layer firewall, telegraf needs an incoming connection
  system.defaults.alf.globalstate = 0;

  # srvos
  environment.etc."ssh/sshd_config.d/darwin.conf".text = ''
    AuthorizedKeysFile none
    HostKey /etc/ssh/ssh_host_ed25519_key
    KbdInteractiveAuthentication no
    PasswordAuthentication no
  '';

  # Make sure to disable netbios on activation
  system.activationScripts.postActivation.text = ''
    echo disabling netbios... >&2
    launchctl disable system/netbiosd
    launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist 2>/dev/null || true
    echo disabling spotlight indexing... >&2
    mdutil -a -i off -d &> /dev/null
    mdutil -a -E &> /dev/null
  '';

  time.timeZone = "GMT";
}

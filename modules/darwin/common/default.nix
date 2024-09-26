{ inputs, ... }:
{
  imports = [
    ./apfs-cleanup.nix
    ./network.nix
    ./optimise.nix
    ./packages.nix
    ./reboot.nix
    ./software-update.nix
    ./telegraf.nix
    ./upgrade-diff.nix
    ./users.nix
    ../../shared/known-hosts.nix
    ../../shared/nix-daemon.nix
    inputs.agenix.darwinModules.age
  ];

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  documentation.enable = false;

  programs.info.enable = false;

  # srvos
  nix.settings.builders-use-substitutes = true;

  # srvos
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.includeUninstaller = false;

  # srvos
  environment.etc."ssh/sshd_config.d/darwin.conf".text = ''
    AuthorizedKeysFile none
    HostKey /etc/ssh/ssh_host_ed25519_key
    KbdInteractiveAuthentication no
    PasswordAuthentication no
  '';

  system.activationScripts.postActivation.text = ''
    echo disabling spotlight indexing... >&2
    mdutil -a -i off -d &> /dev/null
    mdutil -a -E &> /dev/null
  '';

  time.timeZone = "GMT";
}

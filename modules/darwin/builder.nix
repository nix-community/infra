{
  users.knownUsers = [ "nix" ];

  users.users.nix = {
    name = "nix";
    uid = 8765;
    home = "/Users/nix";
    createHome = true;
    shell = "/bin/zsh";
    # if user is removed the keys need to be removed manually from /etc/ssh/authorized_keys.d
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder"
    ];
  };

  # add build user to group for ssh access
  system.activationScripts.postActivation.text = ''
    dseditgroup -o edit -a "nix" -t user com.apple.access_ssh
  '';

  nix.settings.trusted-users = [ "nix" ];
}

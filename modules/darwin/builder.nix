{
  users.knownGroups = [ "nix" ];
  users.knownUsers = [ "nix" ];

  users.groups.nix = {
    name = "nix";
    gid = 8765;
    description = "Group for remote build clients";
  };

  users.users.nix = {
    name = "nix";
    uid = 8765;
    home = "/Users/nix";
    createHome = true;
    shell = "/bin/zsh";
    description = "User for remote build clients";
    # keys are copied, not symlinked
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmdo1x1QkRepZf7nSe+OdEWX+wOjkBLF70vX9F+xf68 builder"
    ];
  };

  nix.settings.trusted-users = [ "nix" ];
}

{
  imports = [
    ../shared/nix-remote-builder.nix
  ];

  users.knownGroups = [ "nix-remote-builder" ];
  users.knownUsers = [ "nix-remote-builder" ];

  users.groups.nix-remote-builder = {
    name = "nix-remote-builder";
    gid = 8765;
    description = "Group for remote build clients";
    members = [ "nix-remote-builder" ];
  };

  users.users.nix-remote-builder = {
    name = "nix-remote-builder";
    uid = 8765;
    home = "/Users/nix-remote-builder";
    createHome = true;
    shell = "/bin/zsh";
    description = "User for remote build clients";
  };
}

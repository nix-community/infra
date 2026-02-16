{ inputs, lib, ... }:

let
  usersDir = "${inputs.self}/users";
  userImports =
    let
      toUserPath = f: usersDir + "/${f}";
      onlyUserFiles = x: lib.hasSuffix ".nix" x && x != "lib.nix";
      userDirEntries = builtins.readDir usersDir;
      userFiles = builtins.filter onlyUserFiles (lib.attrNames userDirEntries);
    in
    map toUserPath userFiles;
in
{
  imports = userImports;

  # users in trusted group are trusted by the nix-daemon
  nix.settings.trusted-users = [ "@trusted" ];

  users.groups.trusted = { };

  # No mutable users
  users.mutableUsers = false;
}

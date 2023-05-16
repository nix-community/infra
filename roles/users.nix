{ inputs, lib, ... }:

let
  usersDir = "${toString inputs.self}/users";
  userImports =
    let
      toUserPath = f: usersDir + "/${f}";
      onlyUserFiles = x:
        lib.hasSuffix ".nix" x &&
        x != "lib.nix"
      ;
      userDirEntries = builtins.readDir usersDir;
      userFiles = builtins.filter onlyUserFiles (lib.attrNames userDirEntries);
    in
    builtins.map toUserPath userFiles;
in
{
  imports = userImports;

  # No mutable users
  users.mutableUsers = false;
}

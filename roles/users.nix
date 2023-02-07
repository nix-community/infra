{ lib, ... }:

let
  userImports =
    let
      toUserPath = f: ../users/. + "/${f}";
      onlyUserFiles = x:
        lib.hasSuffix ".nix" x &&
        x != "lib.nix"
      ;
      userDirEntries = builtins.readDir ../users;
      userFiles = builtins.filter onlyUserFiles (lib.attrNames userDirEntries);
    in
    builtins.map toUserPath userFiles;
in
{
  imports = userImports;

  # No mutable users
  users.mutableUsers = false;
}

{ config, lib, pkgs, ... }:

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

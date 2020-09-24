{ config, pkgs, lib, ... }:

let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO37rmfhCI8e1aflMe1AlfK3zf9tXPHjV9dCb1FBupWt"
  ];

in
{
  users.users.ryantm = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    uid = userLib.mkUid "rytm";
  };

  nix.trustedUsers = [
    "ryantm"
  ];

}

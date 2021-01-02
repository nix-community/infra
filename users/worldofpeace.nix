{ config, pkgs, lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGEkPcumvhBjIZ44tnhN6+hZR8vsCSLD4r1dFzlnXA4 Nix Community - worldofpeace"
  ];

in
{
  users.users.worldofpeace = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    uid = userLib.mkUid "wope";
  };

  nix.trustedUsers = [
    "worldofpeace"
  ];

}

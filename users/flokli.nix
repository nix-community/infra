{ config, pkgs, lib, ... }:

let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTVTXOutUZZjXLB0lUSgeKcSY/8mxKkC0ingGK1whD2 flokli"
  ];
in
{
  users.users.flokli = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    uid = userLib.mkUid "flok";
  };

  nix.trustedUsers = [ "flokli" ];
}

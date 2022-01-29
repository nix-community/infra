{ config, pkgs, lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0B85hC3DH2QDmhbaeAItRSdERs/3kKz+GEDPqDCXeE"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv6hnwYUT6oQvHmRK08IN8GnW9vywF/bpcDEq3jn9QP"
  ];

in
{
  users.users.timo = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel" "trusted"
    ];
    uid = userLib.mkUid "timo";
  };
}

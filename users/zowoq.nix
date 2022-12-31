{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbCYwWByGE46XHH4Q0vZgQ5sOUgbH50M8KO2xhBC4m/"
  ];

in
{
  users.users.zowoq = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "zowo";
  };
}

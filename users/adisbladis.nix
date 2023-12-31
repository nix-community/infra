{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.adisbladis = {
    openssh.authorizedKeys.keyFiles = [ ./keys/adisbladis ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "adis";
  };
}

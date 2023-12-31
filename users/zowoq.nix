{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.zowoq = {
    openssh.authorizedKeys.keyFiles = [ ./keys/zowoq ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "zowo";
  };
}

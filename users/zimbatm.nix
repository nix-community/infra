{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.zimbatm = {
    openssh.authorizedKeys.keyFiles = [ ./keys/zimbatm ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "zimb";
  };
}

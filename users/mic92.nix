{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.mic92 = {
    openssh.authorizedKeys.keyFiles = [ ./keys/mic92 ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "micc";
  };
}

{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.kreyren = {
    openssh.authorizedKeys.keyFiles = [ ./keys/kreyren ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "krey";
  };
}

{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
in
{
  users.users.ryantm = {
    openssh.authorizedKeys.keyFiles = [ ./keys/ryantm ];
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "rytm";
  };
}

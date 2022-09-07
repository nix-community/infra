{ config, pkgs, lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbBp2dH2X3dcU1zh+xW3ZsdYROKpJd3n13ssOP092qE joerg@turingmachine"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC84hXlagpMfElsUwY1f7XA0TUIph301bFA4dCf28mD1I6fw01lNH1KHhWZdHWeaVqhBKdoiNGOvynMGVrH3xVzmf1psILRFaKZkDoKbw6IgtXVDruJjrxCDkkIBokEi7uEH3IBiQnGBHuTWJCwhX+XpnTYUxYzfwlee+S1ZJMrEn3r/R1XsPzXgO0yKCudSgxZqY/QbwJ4WOeJ+1L2WUIoTLA01xzpJsl6N/M2C4HEZZpNokT4gdgRnNRjtmbpkQ5D1Wje2IjneVQMfxmjX+fJPDNiQOALm6aP1jwpLW4LqTY2PXNCj7EyXR269z1QXak13HVdtu9FAer3mgx7icLT roberth"
  ];
in
{
  users.users.mic92 = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "micc";
  };
}

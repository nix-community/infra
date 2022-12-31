{ lib, ... }:
let
  userLib = import ./lib.nix { inherit lib; };
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1e1EG5LUckzjoUiwJZ3ubpKkVN4LmWX5L4rrFimopTdERRM+CU/R7lGpr/msSUNEwMl+5pS/61NS/O7jMOWstVIIdt/ylaY0k71UvrHtdb0YsGPiNx+4+uhavrAmrKaC0wz1rLppqFyzoLxhb6neGrC7zPPHlOvubAVAy73zCL3eDNWuawGoD2mMygSwL1JsaHAxI5fjNA7tyvQIqEfkVki+kWtgZ/0ic19DbtuvFQdECubK3z/IlG1xhKN8Lb2/d9YNI71CMjT0bGYM3qLchmU4WwciLfTBQTqSplNfeIwXMpGvoEl5wbgs1XOXd7wRVlbAE1vb3m6a+e/6gHQ9t"
  ];
in
{
  users.users.lewo = {
    openssh.authorizedKeys.keys = keys;
    useDefaultShell = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "trusted"
    ];
    uid = userLib.mkUid "lewo";
  };
}

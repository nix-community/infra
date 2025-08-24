{ inputs, pkgs, ... }:
{
  imports = [
    inputs.quadlet-nix.nixosModules.default
  ];

  virtualisation.quadlet = {
    enable = true;
    autoUpdate.enable = true;
    autoUpdate.startAt = "*:0/15";
  };

  # https://github.com/mirkolenz/quadlet-nix/blob/c68d1c6b07f76c3ce5a53106b6eee934d86c5391/tests/nixos.nix
  users.users.quadlet = {
    isSystemUser = true;
    uid = 9999;
    linger = true;
    home = "/var/lib/quadlet";
    createHome = true;
    shell = pkgs.shadow;
    autoSubUidGidRange = true;
    group = "quadlet";
  };

  users.groups.quadlet = {
    gid = 9999;
  };
}

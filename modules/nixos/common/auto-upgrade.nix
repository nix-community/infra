{ lib, ... }:
{
  system.autoUpgrade.enable = lib.mkDefault true;
  system.autoUpgrade.flake = "github:nix-community/infra";
  system.autoUpgrade.dates = "hourly";
  system.autoUpgrade.flags = [ "--option" "accept-flake-config" "true" "--option" "tarball-ttl" "0" ];

  # Restart the upgrade service if it fails twice in 5 seconds.
  systemd.services.nixos-upgrade = {
    unitConfig.StartLimitBurst = 2;
    unitConfig.StartLimitIntervalSec = 5;
    serviceConfig.Restart = "on-failure";
  };
}

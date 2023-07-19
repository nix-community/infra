{
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "github:nix-community/infra";
  system.autoUpgrade.dates = "hourly";
  system.autoUpgrade.flags = [ "--option" "accept-flake-config" "true" "--option" "tarball-ttl" "0" ];
}

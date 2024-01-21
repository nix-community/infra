{ inputs, ... }:

{
  imports = [
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
    ./nixpkgs-update.nix
    ./nixpkgs-update-backup.nix
    inputs.self.nixosModules.common
    inputs.self.nixosModules.builder
    inputs.self.nixosModules.disko-raid
  ];

  # workaround for excessive inode usage on this host, `auto-optimise-store` isn't working?
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nixCommunity.disko.raidLevel = 0; # more disk space, we don't have much state to restore anyway

  networking.hostName = "build02";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:41d9::1";

  system.stateVersion = "23.11";
}

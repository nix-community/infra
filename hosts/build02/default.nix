{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./nixpkgs-update-backup.nix
    ./nixpkgs-update-cache.nix
    ./nixpkgs-update.nix
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.self.nixosModules.nginx
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nix-eval-jobs = prev.nix-eval-jobs.overrideAttrs (
        _: p: {
          version = "2.35.2-unstable-2026-08-30";
          src = final.fetchFromGitHub {
            owner = "NixOS";
            repo = "nix-eval-jobs";
            rev = "c026cff507d3f5ea067098d323a2f29e2f634c2f";
            hash = "sha256-FKXrE2qHTHVA7xOHFH+Grm+EaF9Hk+JrTi6VBHrvSuI=";
          };
          buildInputs = (p.buildInputs or [ ]) ++ [ final.mimalloc ];
        }
      );
    })
  ];

  # using latest for mimalloc
  # TODO: switch back to stable nix >= 2.35
  nix.package = pkgs.nixVersions.latest;

  nix.settings.auto-optimise-store = lib.mkForce false;

  nix.settings.cores = config.nix.settings.max-jobs / 3 * 2;
  nix.settings.max-jobs = 24;

  boot.kernelParams = [ "zfs.zfs_arc_max=${toString (24 * 1024 * 1024 * 1024)}" ]; # 24GB, try to limit OOM kills / reboots

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:3b:41d9::1";

  system.stateVersion = "23.11";
}

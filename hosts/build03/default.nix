{ inputs, pkgs, ... }:
{
  imports = [
    ./builders.nix
    ./cache-harmonia.nix
    ./cache-niks3.nix
    ./postgresql.nix
    inputs.self.nixosModules.buildbot
    inputs.self.nixosModules.ci-builder
    inputs.self.nixosModules.disko-zfs-systemd-boot
    inputs.self.nixosModules.freebsd-builder
    inputs.self.nixosModules.github-org-backup
    inputs.self.nixosModules.hercules-ci
    inputs.self.nixosModules.hydra
    inputs.self.nixosModules.nginx
    inputs.self.nixosModules.nixbot
    inputs.self.nixosModules.watch-store
    inputs.srvos.nixosModules.hardware-hetzner-online-amd
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nix-eval-jobs = prev.nix-eval-jobs.overrideAttrs (
        _: p: {
          version = "2.35.2-unstable-2026-09-01";
          src = final.fetchFromGitHub {
            owner = "NixOS";
            repo = "nix-eval-jobs";
            rev = "55e658518ae417cf26f36643fcfdebe5c5db17aa";
            hash = "sha256-4z5GnNd9cbkKChaovYghlxuh1k5rYlxNT7wpZeR1oU0=";
          };
          buildInputs = (p.buildInputs or [ ]) ++ [ final.mimalloc ];
        }
      );
    })
  ];

  nix.package = pkgs.nixVersions.latest;

  nix.settings.extra-platforms = [ "i686-linux" ];

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  nix.settings.max-jobs = 96;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}

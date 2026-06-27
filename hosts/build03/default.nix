{ inputs, ... }:
{
  imports = [
    ./builders.nix
    ./cache-harmonia.nix
    ./postgresql.nix
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
      nix-eval-jobs =
        (prev.nix-eval-jobs.override { nixComponents = final.nixVersions.nixComponents_2_34; })
        .overrideAttrs
          rec {
            version = "2.34.3";
            src = final.fetchFromGitHub {
              owner = "NixOS";
              repo = "nix-eval-jobs";
              tag = "v${version}";
              hash = "sha256-YaVQAgBxWbUBFHXLBLzdUyVvuA/DDw80SEnn9iq0Veo=";
            };
          };
    })
  ];

  nix.settings.extra-platforms = [ "i686-linux" ];

  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  nix.settings.max-jobs = 96;

  systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:2190:2698::2";

  system.stateVersion = "23.11";
}

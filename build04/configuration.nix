{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../roles/common.nix
    ../roles/hercules-ci
    ../roles/remote-builder/user.nix
  ];

  nixpkgs.system = "aarch64-linux";

  # disable default features
  nix.settings.system-features = [ ];

  # we use grub because systemd-boot sometimes fail on aarch64/EFI
  # XXX check if this is still an issue?
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.version = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make it easier to recover via serial console in case something goes wrong.
  services.getty.autologinUser = "root";

  networking.hostName = "build04";
  networking.hostId = "8daf74c0";

  system.stateVersion = "21.11";
  systemd.network = {
    enable = true;
    networks.ethernet.extraConfig = ''
      [Match]
      Type = ether
      [Network]
      DHCP = both
    '';
  };
}

## `opc` is the username from the oracle image. Replace with root if we are booted into nixos.
# nix run github:numtide/nixos-remote#nixos-remote -- \
#   --debug \
#   --kexec "$(nix build --print-out-paths github:nix-community/nixos-images#packages.aarch64-linux.kexec-installer-nixos-unstable)/nixos-kexec-installer-aarch64-linux.tar.gz" \
#   --flake '.#build04' \
#   opc@141.148.235.248

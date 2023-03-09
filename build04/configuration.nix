{
  imports = [
    ./hardware-configuration.nix
    ../roles/common.nix
    ../roles/hercules-ci
    ../roles/remote-builder/user.nix
  ];

  nixpkgs.system = "aarch64-linux";

  # disable kvm/nixos-tests
  nix.settings.system-features = [ "big-parallel" ]; # sync with roles/remote-builder/aarch64-build04.nix

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

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
# nix run github:numtide/nixos-anywhere#nixos-anywhere -- \
#   --debug \
#   --kexec "$(nix build --print-out-paths github:nix-community/nixos-images#packages.aarch64-linux.kexec-installer-nixos-unstable)/nixos-kexec-installer-aarch64-linux.tar.gz" \
#   --flake '.#build04.nix-community.org' \
#   opc@141.148.235.248

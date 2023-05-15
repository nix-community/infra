_:
{
  flake.modules = {
    # Shared modules are compatible both with NixOS and nix-darwin
    shared = {
      common = ./shared/common.nix;
    };

    darwin = {
      common = ./modules/darwin/common.nix;
      remote-builder = ./modules/darwin/remote-builder.nix;
    };

    nixos = {
      common = ./nixos/common.nix;
      raid = ./nixos/raid.nix;
      zfs = ./nixos/zfs.nix;
      builder = ./nixos/builder;
      hercules-ci = ./nixos/hercules-ci;
      remote-builder-aarch64-build04 = ./nixos/remote-builder/aarch64-build04.nix;
      remote-builder-aarch64-nixos-community = ./nixos/remote-builder/aarch64-nixos-community.nix;
      remote-builder-user = ./nixos/remote-builder/user.nix;
      watch-store = ./nixos/watch-store.nix;
    };
  };
}

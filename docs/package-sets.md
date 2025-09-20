#### Nixpkgs unfree redistributable

[unfree redistributable release set in nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/release-unfree-redistributable.nix)

Built on `nixos-unstable-small` for `aarch64-linux`, `x86_64-linux`:

- [https://hydra.nix-community.org/jobset/nixpkgs/unfree-redist](https://hydra.nix-community.org/jobset/nixpkgs/unfree-redist)

Built on `nixos-$RELEASE-small` for `aarch64-linux`, `x86_64-linux`:

- [https://hydra.nix-community.org/jobset/nixpkgs/unfree-redist-stable](https://hydra.nix-community.org/jobset/nixpkgs/unfree-redist-stable)

#### Cache

All of the above builds are pushed to the cache.

See [here](./cache.md) for details.

#### Hydra

The hydra configuration for these package sets is managed in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-nixpkgs.tf).

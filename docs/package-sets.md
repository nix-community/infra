#### Nixpkgs CUDA and ROCm

[CUDA and ROCm release set in nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/release-cuda.nix)

Built on `nixos-unstable-small` for `x86_64-linux`:

- [https://hydra.nix-community.org/jobset/nixpkgs/cuda](https://hydra.nix-community.org/jobset/nixpkgs/cuda)

Built on `nixos-unstable-small` for `x86_64-linux`:

- [https://hydra.nix-community.org/jobset/nixpkgs/rocm](https://hydra.nix-community.org/jobset/nixpkgs/rocm)

Built on `nixos-$RELEASE-small` for `x86_64-linux`:

- [https://hydra.nix-community.org/jobset/nixpkgs/cuda-stable](https://hydra.nix-community.org/jobset/nixpkgs/cuda-stable)

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

#### Nixpkgs CUDA and ROCm

[CUDA and ROCm release set in nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/release-cuda.nix)

Built on `nixos-unstable-small` for `x86_64-linux`, `aarch64-linux` (`aarch64-jetson`):

- [https://hydra.nix-community.org/jobset/nixpkgs/cuda](https://hydra.nix-community.org/jobset/nixpkgs/cuda)

- [https://hydra.nix-community.org/jobset/nixpkgs/rocm](https://hydra.nix-community.org/jobset/nixpkgs/rocm)

Built on `nixos-$RELEASE-small` for `x86_64-linux`, `aarch64-linux` (`aarch64-jetson`):

- [https://hydra.nix-community.org/jobset/nixpkgs/cuda-stable](https://hydra.nix-community.org/jobset/nixpkgs/cuda-stable)

#### Cache

All of the above builds are pushed to the cache.

See [here](./cache.md) for details.

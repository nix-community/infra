We provide `x86_64-linux` and `aarch64-linux` CI via these systems:

#### Hercules

[https://hercules-ci.com/github/nix-community](https://hercules-ci.com/github/nix-community)

To enable hercules builds go to `https://hercules-ci.com/github/nix-community/$REPO` and click "Build this repository".

#### Hydra

[https://hydra.nix-community.org](https://hydra.nix-community.org)

To enable hydra builds add a new project in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-projects.tf).

#### Cache

[https://nix-community.cachix.org/](https://nix-community.cachix.org/)

All of the above CI builds are pushed to the cache.

We provide CI for these platforms:

- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-darwin`
- `x86_64-linux`

We only have limited build capacity for `*-darwin` and `aarch64-linux` so please don't use it excessively.

#### Hercules

[https://hercules-ci.com/github/nix-community](https://hercules-ci.com/github/nix-community)

To enable hercules builds go to `https://hercules-ci.com/github/nix-community/$REPO` and click "Build this repository".

#### Hydra

[https://hydra.nix-community.org](https://hydra.nix-community.org)

To enable hydra builds add a new project in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-projects.tf).

#### Faster GitHub Actions

[namespace](https://cloud.namespace.so) is providing us with Faster GitHub Actions, including ARM64 builders.

Doc: <https://cloud.namespace.so/docs/features/faster-github-actions>.

Limits: see the "Team plan" on <https://cloud.namespace.so/pricing>

#### Cache

[https://nix-community.cachix.org/](https://nix-community.cachix.org/)

All of the above CI builds are pushed to the cache.

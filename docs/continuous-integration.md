We provide CI for these platforms:

- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-darwin`
- `x86_64-linux`

Both `aarch64-linux` and `x86_64-linux` have support for `kvm`/`nixos-test`.

We only have limited build capacity for `*-darwin` so please don't use it excessively.

#### Buildbot

[https://buildbot.nix-community.org](https://buildbot.nix-community.org)

_Buildbot is the only CI system that supports pull requests from forked repositories._

To enable buildbot add the [`nix-community-buildbot`](https://github.com/topics/nix-community-buildbot) topic to the repository.

_Newly enabled repos are imported into buildbot twice a day, you can also ask the admins to trigger an import manually._

#### Hercules

[https://hercules-ci.com/github/nix-community](https://hercules-ci.com/github/nix-community)

To enable hercules go to `https://hercules-ci.com/github/nix-community/$REPO` and click "Build this repository".

#### Hydra

[https://hydra.nix-community.org](https://hydra.nix-community.org)

To enable hydra add a new project in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-projects.tf).

#### Cache

All of the above builds are pushed to the cache.

See [here](./cache.md) for details.

We provide CI for these platforms:

- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-freebsd`
- `x86_64-linux`

Both `aarch64-linux` and `x86_64-linux` have support for `kvm`/`nixos-test`.

We only have limited build capacity for `aarch64-darwin` so please don't use it excessively.

See [here](infrastructure.md#continuous-integration) for details about the hardware.

#### Nixbot

[https://nixbot.nix-community.org](https://nixbot.nix-community.org)

_Nixbot is the only CI system that supports pull requests from forked repositories._
_It also includes support for [status badges](https://mic92.github.io/nixbot/index.html#status-badges) and experimental support for [Hercules CI effects](https://mic92.github.io/nixbot/EFFECTS.html)._

To enable nixbot add the repository to the `repoAllowlist` in this [file](https://github.com/nix-community/infra/blob/master/modules/nixos/nixbot.nix).

#### Hydra

[https://hydra.nix-community.org](https://hydra.nix-community.org)

To enable hydra add a new project in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-projects.tf).

#### Cache

All of the above builds are pushed to the cache.

See [here](cache.md) for details.

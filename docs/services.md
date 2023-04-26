## Community builder

We provide an x86 build machine (`build01.nix-community.org`) as a public remote builder for the nix community, this machine also has an aarch64 machine configured as its own remote builder.

See [here](./community-builder.md) for more information.

## Continuous integration

We provide x86_64 and aarch64 linux CI via these systems:

#### Hercules

[https://hercules-ci.com/github/nix-community](https://hercules-ci.com/github/nix-community)

To enable hercules builds go to `https://hercules-ci.com/github/nix-community/$REPO` and click "Build this repository".

#### Hydra

[https://hydra.nix-community.org](https://hydra.nix-community.org)

To enable hydra builds add a new project in this [file](https://github.com/nix-community/infra/blob/master/terraform/hydra-projects.tf).

## Cache

[https://nix-community.cachix.org/](https://nix-community.cachix.org/)

All of the above CI builds are pushed to the cache.

## Search

[https://search.nix-community.org](https://search.nix-community.org)

Hound code search for NixOS and nix-community GitHub organisations.

## nix-community.org DNS

DNS is managed by terraform in this [file](https://github.com/nix-community/infra/blob/master/terraform/cloudflare_nix-community_org.tf).

## ryantm-updater bot

- Docs: [https://ryantm.github.io/nixpkgs-update](https://ryantm.github.io/nixpkgs-update)
- Logs: [https://r.ryantm.com/log/](https://r.ryantm.com/log/)

## nur-update

[https://github.com/nix-community/nur-update](https://github.com/nix-community/nur-update)

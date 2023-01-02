# nix-community infrastructure

Welcome to the Nix Community infrastructure project. This project holds all the NixOS and Terraform configuration for this organization.

## Community builder

We also provide one x86 hetzner build machine as a public remote builder for the nix community, see [here](roles/builder/README.MD) for more information.

## Hydra

If you want to build your project in our hydra, add a new project in this [file](terraform/hydra-projects.tf).

## Support

If you hit any issues, ping us on Matrix in the [nix-community](https://matrix.to/#/#nix-community:nixos.org) room (see the admin list below) or create an issue here:
[New Issue](https://github.com/nix-community/infra/issues/new).

### Pull requests from forks
As PRs from forks don't have automatic CI checks, admins can test PRs by posting a comment on the PR instead.

* `bors try` - check if the PR builds.
* `bors merge` - same as `bors try` but will also merge the PR if it builds successfully.
* https://bors.tech/documentation/

### Administrators

* @adisbladis
* @flokli
* @grahamc
* @Mic92
* @nlewo
* @ryantm
* @zimbatm
* @zowoq

## Services

* https://search.nix-community.org (hound) - on build03
* https://hydra.nix-community.org - on build03
* matterbridge - on build03
* ryantm-updater bot - on build02

## Hosts

See [HOSTS.md](HOSTS.md), this file also contains deployment details.

## Cache

All the builds on these machines are pushed to https://nix-community.cachix.org/

Thanks to Cachix for sponsoring our binary cache!

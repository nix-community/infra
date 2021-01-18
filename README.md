# nix-community infrastructure

Welcome to the Nix Community infrastructure project. This project holds all
the NixOS and Terraform configuration for this organization.

## Support

If you hit any issues, ping us on IRC in the #nix-community channel (see the
admin list below) or create an issue here:
[New Issue](https://github.com/nix-community/infra/issues/new).

### Administrators

* @adisbladis
* @flokli
* @grahamc
* @Mic92
* @nlewo
* @ryantm
* @zimbatm

## Services

* https://hydra.nix-community.org - on build01
* BuildKite agent - on build01
* GitLab agent - on build01
* ryantm-updater bot - on build01

## Hosts

### `build01` ![build01](https://healthchecks.io/badge/c9e58e14-c706-4084-959b-17b06fbd124f/QFBOLbO1/build01.svg)

This machine is perfect for running heavy builds.

* Provider: Hetzner
* CPU: AMD Ryzen 7 1700X Eight-Core Processor
* RAM: 64GB

All the builds on this machine are pushed to https://nix-community.cachix.org/

Thanks to Cachix for sponsoring our binary cache!

## Usage

* `./deploy` - NixOps deployment
* ./terraform - Setup DNS


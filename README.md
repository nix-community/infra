# nix-community infrastructure

Welcome to the Nix Community infrastructure project. This project holds all
the NixOS and Terraform configuration for this organization.

## Support

If you hit any issues, ping us on Matrix in the
[nix-community](https://matrix.to/#/#nix-community:nixos.org)
room (see the admin list below) or create an issue here:
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

* BuildKite agent - on build01
* GitLab agent - on build01
* hound - on build01
* https://hydra.nix-community.org - on build01
* marvin-mk2 - on build01
* matterbridge - on build01
* ryantm-updater bot - on build02

## Hosts

### `build01` ![build01](https://healthchecks.io/badge/c9e58e14-c706-4084-959b-17b06fbd124f/QFBOLbO1/build01.svg)

This machine is perfect for running heavy builds.

* Provider: Hetzner
* CPU: AMD Ryzen 7 1700X Eight-Core Processor
* RAM: 64GB
* Drives: 2 x 512 GB SATA SSD

### `build02`

This machine currently just runs r-ryantm/nixpkgs-update.

* Provider: Hetzner
* CPU: AMD Ryzen 7 3700X Eight-Core Processor
* RAM: 64GB DDR4 ECC
* Drives: 2 x 1 TB NVME in RAID 1

### `build03`

This machine is a replacement for build01.

* Provider: Hetzner
* CPU: AMD Ryzen 5 3600 6-Core Processor
* RAM: 64GB DDR4 ECC
* Drives: 2 x 512 GB NVME in RAID 1

### `build04`

This machine is meant as an aarch64 builder for our hydra instance running on build03.

* Provider: Oracle cloud
* Instance type: [Ampere A1 Compute](https://www.oracle.com/cloud/compute/arm/)
* CPU: 4 VCPUs on an Ampere Altra (arm64) 
* RAM: 24GB
* Drives: 200 GB Block

## Cache

All the builds on these machines are pushed to https://nix-community.cachix.org/

Thanks to Cachix for sponsoring our binary cache!

## File hierarchy

* ./build\d+ - build machines
* ./ci.sh - What is executed by CI
* ./deploy - Deploy script
* ./nix - pinned Nix dependencies and overlays
* ./roles - shared NixOS configuration modules
* ./secrets - git-crypt encrypted secrets
* ./services - single instances of NixOS services
* ./terraform - Setup DNS
* ./users - NixOS configuration of our admins

## Deployment commands:

```console
$ ./deploy
```

If you want to reboot a machine, use the following
command to also deploy secrets afterwards:

```console
$ inv deploy --hosts build02 reboot --hosts build02
```

## Install/Fix system from Hetzner recovery mode
1. Install kexec image from Hetzner recovery system as described in [kexec.nix](roles/kexec.nix) and boot into it

2. Format and/or mount all filesystems to /mnt:

```console
$ inv format-disks --hosts buildXX --disks /dev/nvme0n1,/dev/nvme1n1
```

3. Setup secrets

```console
$ inv setup-secret --hosts buildXX
```

4. Generate configuration and download to the repo

```console
$ nixos-generate-config  --root /tmp
# optional, in most cases one can roles/hardware/hetzner-amd.nix
$ scp buildXX.nix-community.org:/tmp/etc/nixos/hardware-configuration.nix buildXX/hardware-configuration.nix
```

5. Build and install

```console
$ inv install-nixos --hosts buildXX
```

### Debug VM

You can start a vm from the rescue system in order to debug the boot:

```console
$ nix-shell -p qemu_kvm --run 'qemu-kvm -m 10G -hda /dev/sda -hdb /dev/sdb -curses -cpu host -enable-kvm'
```

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

### `build01`

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

## Deployment commands:

```console
$ ./deploy
```

If you want to reboot a machine, use the following command to also deploy secrets afterwards:

```console
$ inv deploy --hosts build02 reboot --hosts build02
```

## Install/Fix system from Hetzner recovery mode

1. Copy your ssh key to the recovery system so that the kexec image can re-use it.

``` console
yourmachine> ssh-copy-id root@build0X.nix-community.org
```

2. Download and boot into kexec-image:

``` console
$ curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-x86_64-linux.tar.gz | tar -xzf- -C /root
$ /root/kexec/run
```

3. Format and/or mount all filesystems to /mnt:

```console
$ inv format-disks --hosts buildXX --disks /dev/nvme0n1,/dev/nvme1n1
```

4. Setup secrets

```console
$ inv setup-secret --hosts buildXX
```

5. Generate configuration and download to the repo

```console
$ nixos-generate-config  --root /tmp
# optional, in most cases one can import roles/hetzner/amd.nix
$ scp buildXX.nix-community.org:/tmp/etc/nixos/hardware-configuration.nix buildXX/hardware-configuration.nix
```

6. Build and install

```console
$ inv install-nixos --hosts buildXX
```

### Debug VM

You can start a vm from the rescue system in order to debug the boot:

```console
$ nix-shell -p qemu_kvm --run 'qemu-kvm -m 10G -hda /dev/sda -hdb /dev/sdb -curses -cpu host -enable-kvm'
```

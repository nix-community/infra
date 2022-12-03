# nix-community infrastructure

Welcome to the Nix Community infrastructure project. This project holds all the NixOS and Terraform configuration for this organization.

## Community builder

We also provide one x86 hetzner build machine as a public remote builder for the nix community. If you want access read the security guide lines on [aarch64-build-box](https://github.com/nix-community/aarch64-build-box). Than add your username to `roles/builder/users.nix`. Don't keep any important data in your home! We will regularly delete `/home` without further notice.

### Using your NixOS home-manager configuration on the hosts

If you happen to have your NixOS & home-manager configurations intertwined but you'd like your familiar environment on our infrastructure you can evaluate `pkgs.writeShellScript "hm-activate" config.systemd.services.home-manager-<yourusername>.serviceConfig.ExecStart` from your NixOS configuration, and send this derivation to be realized remotely: (in case you aren't a Nix trusted user)
``` console
# somehow get the .drv of the above expression into $path
$ nix copy --to ssh://build01.nix-community.org --derivation $path
$ ssh build01.nix-community.org
$ nix-store -r $path
$ $path
```

*(My [implementation](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/deploy/hm-only.nix#L10) of [this](https://github.com/ckiee/nixfiles/blob/aac57f56e417e31f00fd495d8a30fb399ecbc19b/bin/c#L92-L95) ~ckie)*

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

## File hierarchy

* ./build\d+ - build machines
* ./ci.sh - What is executed by CI
* ./deploy - Deploy script
* ./roles - shared NixOS configuration modules
* ./services - single instances of NixOS services
* ./terraform - Setup DNS
* ./users - NixOS configuration of our admins

## Deployment commands:

```console
$ ./deploy
```

If you want to reboot a machine, use the following command to also deploy secrets afterwards:

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
# optional, in most cases one can import roles/hardware/hetzner-amd.nix
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

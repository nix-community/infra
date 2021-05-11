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
* Drives: 2 x 512 TB NVME in RAID 1

## Cache

All the builds on these machines are pushed to https://nix-community.cachix.org/

Thanks to Cachix for sponsoring our binary cache!

## File hierarchy

* ./build\d+ - build machines
* ./ci.sh - What is executed by CI
* ./deploy - NixOps deploy script
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
$ ./deploy --force-reboot --include build02
```

## Install/Fix system from Hetzner recovery mode
1. Format and/or mount all filesystems to /mnt:

``` console
# format disk with as follow:
# - partition 1 will be the boot partition, needed for legacy (BIOS) boot
# - partition 2 is for boot partition
# - partition 3 takes up the rest of the space and is for the system
$ sgdisk -n 1:2048:4095 -n 2:4096:+512M -N 3 -t 1:ef02 -t 2:8304 -t 3:8304 /dev/nvme0n1
$ sgdisk -n 1:2048:4095 -n 2:4096:+512M -N 3 -t 1:ef02 -t 2:8304 -t 3:8304 /dev/nvme1n1
# create mdadm raid for /boot with ext4
$ sudo mdadm --create --verbose /dev/md127 --level=0 --raid-devices=2 /dev/nvme{0,1}n1p2
$ sudo mkfs.ext4 -F /dev/md127
# format zpool
$ zpool create zroot -O acltype=posixacl -O xattr=sa -O compression=lz4 mirror /dev/nvme{0,1}n1p3
$ zfs create -o mountpoint=none zroot/root
$ zfs create -o mountpoint=legacy zroot/root/nixos
$ zfs create -o mountpoint=legacy zroot/root/home

# and finally mount
$ mount -t zfs zroot/root/nixos /mnt
$ mkdir /mnt/{home,boot}
$ mount -t zfs zroot/root/home /mnt/home
$ mount -t ext4 /dev/md127 /mnt/boot
```

2. Install kexec image from Hetzner recovery system as described in [kexec.nix](roles/kexec.nix) and boot into it
3. Download infra repo
``` console
$ nix-shell -p git --run "git clone https://github.com/nix-community/infra && cd infra && nix-shell"
# Just in case generate hardware-configuration.nix and compare it with what we have in the repos
$ nixos-generate-config  --root /mnt
$ diff -aur /mnt/etc/nixos/hardware-configuration.nix buildXX/hardware-configuration.nix
```

4. Build new system closure:

``` console
nix-shell> nix-build -A buildXX-system
```

5. Install system closure

```console
$ nixos-install --system ./result
```

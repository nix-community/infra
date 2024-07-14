## Hosts

### `build01`

- Provider: Hetzner
- Instance type: [AX41](https://www.hetzner.com/dedicated-rootserver/ax41-nvme)
- CPU: AMD Ryzen 5 3600 6-Core Processor
- RAM: 64GB DDR4 ECC
- Drives: 2 x 512 GB NVME in RAID 0

### `build02`

- Provider: Hetzner
- CPU: AMD Ryzen 9 3900 12-Core Processor
- RAM: 128GB DDR4 ECC
- Drives: 2 x 1.92 TB NVME in RAID 0

### `build03`

- Provider: Hetzner
- CPU: AMD Ryzen 9 3900 12-Core Processor
- RAM: 128GB DDR4 ECC
- Drives: 2 x 1.92 TB NVME in RAID 0

### `build04`

- Provider: Hetzner
- Instance type: [RX170](https://www.hetzner.com/dedicated-rootserver/rx170)
- CPU: Ampere Altra Q80-30 80-Core Processor
- RAM: 128GB DDR4 ECC
- Drives: 2 x 960 GB NVME in RAID 0

### `darwin01`

- Provider: OakHost
- Instance type: [Apple Mac mini M2](https://www.oakhost.net/product/mac-mini-hosting-m2-24gb)
- CPU: Apple M2
- RAM: 24GB
- Drives: 1 TB SSD

### `darwin02`

- Provider: OakHost
- Instance type: [Apple Mac mini M2](https://www.oakhost.net/product/mac-mini-hosting-m2-24gb)
- CPU: Apple M2
- RAM: 24GB
- Drives: 1 TB SSD

### `web02`

- Provider: Gandi
- Instance type: [V-R4](https://www.gandi.net/en-GB/cloud/vps)
- CPU: 2 CPU
- RAM: 4GB
- Drives: 25GB

## SSH config:

You will need to set your admin username if it doesn't match your local username.

```
Host *.nix-community.org
  User <youradminusername>
```

## Deployment commands:

```console
$ ./inv deploy
```

If you want to reboot a machine, use the following command:

```console
$ inv deploy --hosts build02 reboot --hosts build02
```

## Install/Fix system from Hetzner recovery mode

1. Copy your ssh key to the recovery system so that the kexec image can re-use it.

```console
yourmachine> ssh-copy-id root@build0X.nix-community.org
```

2. Download and boot into kexec-image:

```console
$ curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-x86_64-linux.tar.gz | tar -xzf- -C /root
$ /root/kexec/run
```

## Fix up broken installations with disko-install

Disko install allows to update nixos configuration with out re-formatting, if the `--mode` parameter is set to `mount`. This assumes that the file system is still intact. `--disk` may need to be adjusted according to the concrete disko configuration. i.e. disks during installation may have different names than later in the recovery system. Use lsblk or `/dev/disk/by-partlabel` to reason about which disk is which.

```console
$ ls -la /dev/disk/by-partlabel/
total 0
drwxr-xr-x  2 root root 120 Jul 11 21:45 .
drwxr-xr-x 11 root root 220 Jul 11 21:45 ..
lrwxrwxrwx  1 root root  15 Jul 11 21:45 disk-nvme0n1-boot -> ../../nvme1n1p1
lrwxrwxrwx  1 root root  15 Jul 11 21:45 disk-nvme0n1-ESP -> ../../nvme1n1p2
lrwxrwxrwx  1 root root  15 Jul 11 21:45 disk-nvme0n1-zfs -> ../../nvme1n1p3
lrwxrwxrwx  1 root root  15 Jul 11 21:45 disk-nvme1n1-zfs -> ../../nvme0n1p1
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0 310.8M  0 loop /nix/.ro-store
loop1         7:1    0    36K  0 loop
nvme1n1     259:0    0   1.7T  0 disk
├─nvme1n1p1 259:3    0     1M  0 part
├─nvme1n1p2 259:4    0     1G  0 part
└─nvme1n1p3 259:5    0   1.7T  0 part
nvme0n1     259:1    0   1.7T  0 disk
└─nvme0n1p1 259:2    0   1.7T  0 part
$ nix run github:nix-community/disko#disko-install -- --mode mount --flake github:nix-community/infra#build02 --disk nvme0n1 /dev/nvme1n1 --disk nvme1n1 /dev/nvme0n1
```

### Debug VM

You can start a vm from the rescue system in order to debug the boot:

```console
$ nix-shell -p qemu_kvm --run 'qemu-kvm -m 10G -hda /dev/sda -hdb /dev/sdb -curses -cpu host -enable-kvm'
```

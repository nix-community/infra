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
- Drives: 2 x 1.92 TB NVME in RAID 1

### `build04`

- Provider: Hetzner
- Instance type: [RX170](https://www.hetzner.com/dedicated-rootserver/rx170)
- CPU: Ampere Altra Q80-30 80-Core Processor
- RAM: 128GB DDR4 ECC
- Drives: 2 x 960 GB NVME in RAID 0

### `darwin01`

- Provider: Hetzner
- Instance type: [Apple Mac mini M1](https://docs.hetzner.com/robot/dedicated-server/mac-mini/getting-started/)
- CPU: Apple M1
- RAM: 16GB
- Drives: 256GB SSD, 2 x 1 TB NVME in RAID 0

### `darwin02`

- Provider: Hetzner
- Instance type: [Apple Mac mini M1](https://docs.hetzner.com/robot/dedicated-server/mac-mini/getting-started/)
- CPU: Apple M1
- RAM: 16GB
- Drives: 256GB SSD

### `darwin03`

- Provider: Hetzner
- Instance type: [Apple Mac mini M1](https://docs.hetzner.com/robot/dedicated-server/mac-mini/getting-started/)
- CPU: Apple M1
- RAM: 16GB
- Drives: 256GB SSD

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

### Debug VM

You can start a vm from the rescue system in order to debug the boot:

```console
$ nix-shell -p qemu_kvm --run 'qemu-kvm -m 10G -hda /dev/sda -hdb /dev/sdb -curses -cpu host -enable-kvm'
```

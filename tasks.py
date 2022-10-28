#!/usr/bin/env python3

from invoke import task

import sys
from typing import List, Any
from deploykit import DeployHost, DeployGroup
import subprocess
import json

RSYNC_EXCLUDES = [".terraform", ".direnv", ".mypy-cache", ".git"]


def deploy_nixos(hosts: List[DeployHost]) -> None:
    """
    Deploy to all hosts in parallel
    """
    g = DeployGroup(hosts)

    def deploy(h: DeployHost) -> None:
        target = f"{h.user or 'root'}@{h.host}"
        h.run_local(
            f"rsync {' --exclude '.join([''] + RSYNC_EXCLUDES)} -vaF --delete -e ssh . {target}:/etc/nixos"
        )

        h.run(f"nixos-rebuild switch --option accept-flake-config true")

    g.run_function(deploy)


def sfdisk_json(host: DeployHost, dev: str) -> List[Any]:
    out = host.run(f"sfdisk --json {dev}", stdout=subprocess.PIPE)
    data = json.loads(out.stdout)
    return data["partitiontable"]["partitions"]


def _format_disks(host: DeployHost, devices: List[str]) -> None:
    assert (
        len(devices) == 1 or len(devices) == 2
    ), "we only support single devices or mirror raids at the moment"
    # format disk with as follow:
    # - partition 1 will be the boot partition, needed for legacy (BIOS) boot
    # - partition 2 is for boot partition
    # - partition 3 takes up the rest of the space and is for the system
    for device in devices:
        host.run(
            f"sgdisk -Z -n 1:2048:4095 -n 2:4096:+2G -N 3 -t 1:ef02 -t 2:8304 -t 3:8304 {device}"
        )

    # create mdadm raid for /boot with ext4
    if len(devices) == 2:
        boot_parts = []
        root_parts = []
        for dev in devices:
            # use partuuids as they are more stable than device names
            partitions = sfdisk_json(host, dev)
            boot_parts.append(partitions[1]["node"])
            root_parts.append(f"/dev/disk/by-partuuid/{partitions[2]['uuid'].lower()}")

        host.run(
            f"mdadm --create --verbose /dev/md127 --raid-devices=2 --level=1 {' '.join(boot_parts)}"
        )
        host.run(
            f"zpool create zroot -O acltype=posixacl -O xattr=sa -O compression=lz4 mirror {' '.join(root_parts)}"
        )
        boot = "/dev/md127"
    else:
        partitions = sfdisk_json(host, devices[0])
        boot = partitions[1]["node"]
        uuid = partitions[2]["uuid"].lower()
        root_part = f"/dev/disk/by-partuuid/{uuid}"
        host.run(
            f"zpool create zroot -O acltype=posixacl -O xattr=sa -O compression=lz4 -O atime=off {root_part}"
        )

    host.run(f"partprobe")
    host.run(f"mkfs.ext4 -F {boot}")

    # setup zfs dataset
    host.run(f"zfs create -o mountpoint=none zroot/root")
    host.run(f"zfs create -o mountpoint=legacy zroot/root/nixos")
    host.run(f"zfs create -o mountpoint=legacy zroot/root/home")

    ## and finally mount
    host.run(f"mount -t zfs zroot/root/nixos /mnt")
    host.run(f"mkdir /mnt/home /mnt/boot")
    host.run(f"mount -t zfs zroot/root/home /mnt/home")
    host.run(f"mount -t ext4 /dev/md127 /mnt/boot")


@task
def update_sops_files(c):
    """
    Update all sops yaml and json files according to .sops.yaml rules
    """

    c.run(
        """
find . \
        -not -path "./.github/*" \
        -not -path "./.mergify.yml" \
        -not -path "./_config.yml" \
        -type f \
        \( -iname '*.enc.json' -o -iname '*.yaml' \) \
        -print0 | \
        xargs -0 -n1 sops updatekeys --yes
"""
    )


@task
def format_disks(c, hosts="", disks=""):
    """
    Format disks with zfs, i.e.: inv format-disks --hosts build02 --disks /dev/nvme0n1,/dev/nvme1n1
    """
    for h in get_hosts(hosts):
        _format_disks(h, disks.split(","))


@task
def setup_secret(c, hosts=""):
    """
    Setup SSH key and print age key for sops-nix
    """
    for h in get_hosts(hosts):
        h.run(
            "install -m600 -D /etc/ssh/ssh_host_rsa_key /mnt/etc/ssh/ssh_host_rsa_key"
        )
        h.run(
            "install -m600 -D /etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key"
        )
        print(h.host)
        h.run(
            "nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'"
        )


@task
def nixos_install(c, hosts=""):
    """
    Run NixOS install
    """
    for h in get_hosts(hosts):
        h.run(
            "nix-shell -p git --run 'git clone https://github.com/nix-community/infra && cd infra && nix-shell'"
        )
        hostname = h.host.replace(".nix-community.org", "")
        h.run(
            f"cd /root/infra && nixos-install --system $(nix-build -A {hostname}-system)"
        )


def get_hosts(hosts: str) -> List[DeployHost]:
    if hosts == "":
        return [
            DeployHost(f"build{n + 1:02d}.nix-community.org", user="root")
            for n in range(4)
        ]

    return [DeployHost(f"{h}.nix-community.org", user="root") for h in hosts.split(",")]


@task
def deploy(c, hosts=""):
    """
    Deploy to all servers. Use inv deploy --host build01 to deploy to a single server
    """
    deploy_nixos(get_hosts(hosts))


def wait_for_port(host: str, port: int, shutdown: bool = False) -> None:
    import socket, time

    while True:
        try:
            with socket.create_connection((host, port), timeout=1):
                if shutdown:
                    time.sleep(1)
                    sys.stdout.write(".")
                    sys.stdout.flush()
                else:
                    break
        except OSError as ex:
            if shutdown:
                break
            else:
                time.sleep(0.01)
                sys.stdout.write(".")
                sys.stdout.flush()


@task
def reboot(c, hosts=""):
    """
    Reboot hosts. example usage: inv reboot --hosts build01,build02
    """
    for h in get_hosts(hosts):
        h.run("reboot &")

        print(f"Wait for {h.host} to shutdown", end="")
        sys.stdout.flush()
        wait_for_port(h.host, h.port, shutdown=True)
        print("")

        print(f"Wait for {h.host} to start", end="")
        sys.stdout.flush()
        wait_for_port(h.host, h.port)
        print("")


@task
def cleanup_gcroots(c, hosts=""):
    g = DeployGroup(get_hosts(hosts))
    g.run("find /nix/var/nix/gcroots/auto -type s -delete")
    g.run("systemctl restart nix-gc")

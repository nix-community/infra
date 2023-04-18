#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import List

from deploykit import DeployGroup, DeployHost
from invoke import task

ROOT = Path(__file__).parent.resolve()
os.chdir(ROOT)


# Deploy to all hosts in parallel
def deploy_nixos(hosts: List[DeployHost]) -> None:
    g = DeployGroup(hosts)

    res = subprocess.run(
        ["nix", "flake", "metadata", "--json"],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    data = json.loads(res.stdout)
    path = data["path"]

    def deploy(h: DeployHost) -> None:
        h.run_local(
            f"rsync --rsync-path='sudo rsync' --checksum -vaF --delete -e ssh {path}/ {h.host}:/etc/nixos"
        )

        hostname = h.host.replace(".nix-community.org", "")
        h.run(
            [
                "sudo",
                "nixos-rebuild",
                "switch",
                "--option",
                "accept-flake-config",
                "true",
                "--flake",
                f"/etc/nixos#{hostname}",
            ]
        )

    g.run_function(deploy)


@task
def update_sops_files(c):
    """
    Update all sops yaml and json files according to .sops.yaml rules
    """
    c.run(
        """
find . \
        -type f \
        \( -iname '*.enc.json' -o -iname 'secrets.yaml' \) \
        -exec sops updatekeys --yes {} \;
"""
    )


@task
def scan_age_keys(c, host):
    """
    Scans for the host key via ssh an converts it to age. Use inv scan-age-keys build**.nix-community.org
    """
    proc = subprocess.run(
        ["ssh-keyscan", host], stdout=subprocess.PIPE, text=True, check=True
    )
    print("###### Age keys ######")
    subprocess.run(
        ["ssh-to-age"],
        input=proc.stdout,
        check=True,
        text=True,
    )


@task
def update_terraform(c):
    """
    Update terraform devshell flake
    """
    with c.cd("terraform"):
        c.run(
            """
system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
old="$(nix build --no-link --print-out-paths ".#devShells.${system}.default")"
nix flake update --commit-lock-file
new="$(nix build --no-link --print-out-paths ".#devShells.${system}.default")"
commit="$(git log --pretty=format:%B -1)"
diff="$(nix store diff-closures "${old}" "${new}" | awk -F ',' '/terraform/ && /→/ {print $1}')"
git commit --amend -m "${commit}" -m "Terraform updates:" -m "${diff}"
"""
        )


@task
def mkdocs(c):
    """
    Serve docs (mkdoc serve)
    """
    c.run("nix develop .#pages -c mkdocs serve")


def get_hosts(hosts: str) -> List[DeployHost]:
    if hosts == "":
        return [DeployHost(f"build{n + 1:02d}.nix-community.org") for n in range(4)]

    return [DeployHost(f"{h}.nix-community.org") for h in hosts.split(",")]


@task
def deploy(c, hosts=""):
    """
    Deploy to all servers. Use inv deploy --hosts build01 to deploy to a single server
    """
    deploy_nixos(get_hosts(hosts))


@task
def build_local(c, hosts=""):
    """
    Build all servers. Use inv build-local --hosts build01 to build a single server
    """
    g = DeployGroup(get_hosts(hosts))

    def build_local(h: DeployHost) -> None:
        hostname = h.host.replace(".nix-community.org", "")
        h.run_local(
            [
                "nixos-rebuild",
                "build",
                "--option",
                "accept-flake-config",
                "true",
                "--flake",
                f".#{hostname}",
            ]
        )

    g.run_function(build_local)


def wait_for_port(host: str, port: int, shutdown: bool = False) -> None:
    import socket
    import time

    while True:
        try:
            with socket.create_connection((host, port), timeout=1):
                if shutdown:
                    time.sleep(1)
                    sys.stdout.write(".")
                    sys.stdout.flush()
                else:
                    break
        except OSError:
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
        h.run("sudo reboot &")

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
    g.run("sudo find /nix/var/nix/gcroots/auto -type s -delete")
    g.run("sudo systemctl restart nix-gc")

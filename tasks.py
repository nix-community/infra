#!/usr/bin/env python3

import json
import os
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any, List, Union

from deploykit import DeployGroup, DeployHost
from invoke import task

ROOT = Path(__file__).parent.resolve()
os.chdir(ROOT)


@task
def redeploykeys(c: Any, hosts: str) -> None:
    g = DeployGroup(get_hosts(hosts))

    def deploy(h: DeployHost) -> None:
        with TemporaryDirectory() as tmpdir:
            hostname = h.host.replace(".nix-community.org", "")
            flake_attr = hostname
            dir = "/var/lib/ssh_secrets"
            decrypt_host_key(flake_attr, tmpdir)
            h.run(f"sudo rm -rfv {dir}")
            h.run(f"sudo mkdir -pv {dir}")
            h.run_local(
                f"cat {tmpdir}{dir}/ssh_host_ed25519_key | ssh {h.host} 'sudo tee {dir}/ssh_host_ed25519_key'"
            )
            h.run_local(
                f"cat {tmpdir}{dir}/initrd_host_ed25519_key | ssh {h.host} 'sudo tee {dir}/initrd_host_ed25519_key'"
            )
            h.run(f"sudo chown root:root {dir}/*")
            h.run(f"sudo chmod 400 {dir}/*")
            h.run(f"stat -c '%a %U %G %n' {dir}/*")

    g.run_function(deploy)


@task
def deploy(c: Any, hosts: str) -> None:
    """
    Use inv deploy --hosts build01,darwin01
    """
    g = DeployGroup(get_hosts(hosts))

    def deploy(h: DeployHost) -> None:
        if "darwin" in h.host:
            command = "sudo -H darwin-rebuild"
            target = f"{h.user}@{h.host}"
        else:
            command = "sudo nixos-rebuild"
            target = f"{h.host}"

        res = subprocess.run(
            ["nix", "flake", "metadata", "--json"],
            text=True,
            check=True,
            stdout=subprocess.PIPE,
        )
        data = json.loads(res.stdout)
        path = data["path"]

        send = (
            "nix flake archive"
            if any(
                (
                    n.get("locked", {}).get("type") == "path"
                    or n.get("locked", {}).get("url", "").startswith("file:")
                )
                for n in data["locks"]["nodes"].values()
            )
            else f"nix copy {path}"
        )

        h.run_local(f"{send} --to ssh://{target}")

        hostname = h.host.replace(".nix-community.org", "")
        h.run(
            f"{command} switch --option accept-flake-config true --flake {path}#{hostname}"
        )

    g.run_function(deploy)


@task
def sotp(c: Any, acct: str) -> None:
    """
    Get TOTP token from sops
    """
    c.run(f"nix develop .#sotp -c sotp {acct}")


@task
def update_sops_files(c: Any) -> None:
    """
    Update all sops yaml files according to sops.nix rules
    """
    with open(f"{ROOT}/.sops.yaml", "w") as f:
        print("# AUTOMATICALLY GENERATED WITH: $ inv update-sops-files", file=f)

    c.run(f"nix eval --json -f {ROOT}/sops.nix | yq e -P - >> {ROOT}/.sops.yaml")
    c.run(
        "shopt -s globstar && sops updatekeys --yes **/secrets.yaml modules/secrets/*.yaml"
    )


@task
def print_keys(c: Any, flake_attr: str) -> None:
    """
    Decrypt host private key, print ssh and age public keys. Use inv print-keys --flake-attr build01
    """
    with TemporaryDirectory() as tmpdir:
        decrypt_host_key(flake_attr, tmpdir)
        key = f"{tmpdir}/var/lib/ssh_secrets/ssh_host_ed25519_key"
        pubkey = subprocess.run(
            ["ssh-keygen", "-y", "-f", f"{key}"],
            stdout=subprocess.PIPE,
            text=True,
            check=True,
        )
        print("###### Public keys ######")
        print(pubkey.stdout)
        print("###### Age keys ######")
        subprocess.run(
            ["ssh-to-age"],
            input=pubkey.stdout,
            check=True,
            text=True,
        )


@task
def docs(c: Any) -> None:
    """
    Serve docs (mkdoc serve)
    """
    c.run("nix develop .#mkdocs -c mkdocs serve")


@task
def docs_linkcheck(c: Any) -> None:
    """
    Run docs online linkchecker
    """
    c.run("nix run .#docs-linkcheck.online")


def get_hosts(hosts: str) -> List[DeployHost]:
    deploy_hosts = []
    for host in hosts.split(","):
        if host.startswith("darwin"):
            deploy_hosts.append(
                DeployHost(f"{host}.nix-community.org", user="customer")
            )
        else:
            deploy_hosts.append(DeployHost(f"{host}.nix-community.org"))

    return deploy_hosts


def decrypt_host_key(flake_attr: str, tmpdir: str) -> None:
    def opener(path: str, flags: int) -> Union[str, int]:
        return os.open(path, flags, 0o400)

    t = Path(tmpdir)
    t.mkdir(parents=True, exist_ok=True)
    t.chmod(0o755)

    def decrypt(path: str, secret: str) -> None:
        file = t / path
        file.parent.mkdir(parents=True, exist_ok=True)
        with open(file, "w", opener=opener) as fh:
            subprocess.run(
                [
                    "sops",
                    "--extract",
                    secret,
                    "--decrypt",
                    f"{ROOT}/secrets.yaml",
                ],
                check=True,
                stdout=fh,
            )

    decrypt(
        "var/lib/ssh_secrets/ssh_host_ed25519_key",
        f'["ssh_host_ed25519_key"]["{flake_attr}"]',
    )
    decrypt(
        "var/lib/ssh_secrets/initrd_host_ed25519_key", '["initrd_host_ed25519_key"]'
    )


@task
def install(c: Any, flake_attr: str, hostname: str) -> None:
    """
    Decrypt host private key, install with nixos-anywhere. Use inv install --flake-attr build01 --hostname build01.nix-community.org
    """
    ask = input(f"Install {hostname} with {flake_attr}? [y/N] ")
    if ask != "y":
        return
    with TemporaryDirectory() as tmpdir:
        decrypt_host_key(flake_attr, tmpdir)
        flags = "--build-on-remote --debug --option accept-flake-config true"
        c.run(
            f"nix run --inputs-from . nixpkgs#nixos-anywhere -- {hostname} --extra-files {tmpdir} --flake .#{flake_attr} {flags}",
            echo=True,
        )


@task
def cleanup_gcroots(c: Any, hosts: str) -> None:
    g = DeployGroup(get_hosts(hosts))
    g.run("sudo find /nix/var/nix/gcroots/auto -type s -delete")

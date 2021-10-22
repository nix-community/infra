#!/usr/bin/env python3

from invoke import task

import sys
from typing import List
from deploy_nixos import DeployHost, DeployGroup


def deploy_nixos(hosts: List[DeployHost]) -> None:
    """
    Deploy to all hosts in parallel
    """
    g = DeployGroup(hosts)
    def deploy(h: DeployHost) -> None:
        h.run_local(
            f"rsync --exclude='.git/' -vaF --delete -e ssh . {h.user}@{h.host}:/etc/nixos",
        )

        config = f"/etc/nixos/{h.host.replace('.nix-community.org', '')}/configuration.nix"
        h.run(f"nixos-rebuild switch -I nixos-config={config} -I nixpkgs=$(nix-instantiate --eval -E '(import /etc/nixos/nix {{}}).path')")
    g.run_function(deploy)



def get_hosts(hosts: str):
    if hosts == "":
        return [DeployHost(f"build{n + 1}.nix-community.org") for n in range(4)]

    return [DeployHost(f"{h}.nix-community.org") for h in hosts.split(",")]


@task
def deploy(c, hosts = ""):
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
    deploy_hosts = get_hosts(hosts)
    for h in deploy_hosts:
        g = DeployGroup([h])
        g.run("reboot &")

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

#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.python -p python3Packages.requests

import json
import os

import requests

github_token = os.environ.get("GITHUB_TOKEN")

disallowed_repos = [
    "nix-community/dream2nix-auto-test",
    "nix-community/image-spec",
    "nix-community/nix",
    "nix-community/nixpkgs",
    "nix-community/nsncd",
    "nix-community/rkwifibt",
    "NixOS/nixops-dashboard",  # empty repo causes an error
]


def all_for_org(org):

    resp = {}

    next_url = "https://api.github.com/orgs/{}/repos".format(org)
    while next_url is not None:

        if github_token is not None:
            headers = {"Authorization": f"token {github_token}"}
            repo_resp = requests.get(next_url, headers=headers)
        else:
            repo_resp = requests.get(next_url)

        if "next" in repo_resp.links:
            next_url = repo_resp.links["next"]["url"]
        else:
            next_url = None

        repos = repo_resp.json()

        resp.update(
            {
                "{}-{}".format(org, repo["name"]): {
                    "url": repo["clone_url"],
                }
                for repo in repos
                if repo["full_name"] not in disallowed_repos
                if repo["archived"] is False
            }
        )

    return resp


repos = {**all_for_org("NixOS"), **all_for_org("nix-community")}

print(
    json.dumps(
        {
            "max-concurrent-indexers": 1,
            "dbpath": "/var/lib/hound/data",
            "repos": repos,
            "vcs-config": {"git": {"detect-ref": True}},
        },
        indent=2,
        sort_keys=True,
    )
)

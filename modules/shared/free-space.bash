nix-env --delete-generations 1d --profile /nix/var/nix/profiles/system
harmonia-gc --no-vacuum --keep-recent 1d --ensure-free 20%

nix-env --delete-generations 1d --profile /nix/var/nix/profiles/system
fast-nix-gc --no-vacuum --keep-recent 1d --ensure-free 15%
# disable optimise store on the nixpkgs-update host
if [[ "$(uname -n)" != "build02" ]]; then
  # run optimise every six hours
  if ((10#$(date +%H) % 6 == 0)); then
    fast-nix-optimise
  fi
fi

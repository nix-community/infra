FREE="$(df -BG / | awk 'NR==2 {gsub("G","",$2); print $2 * 0.15 "G"}')"
nix-env --delete-generations 1d --profile /nix/var/nix/profiles/system
fast-nix-gc --keep-recent 1d --ensure-free "$FREE"
if (($(date +%H) % 6 == 0)); then
  fast-nix-optimise
fi

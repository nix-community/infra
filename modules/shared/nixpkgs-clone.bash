CLONE_DIR="/var/lib/nixpkgs.git"
if [ ! -d "$CLONE_DIR" ]; then
  git clone --bare https://github.com/NixOS/nixpkgs.git "$CLONE_DIR"
fi
git -C "$CLONE_DIR" -c remote.origin.fetch="+refs/heads/*:refs/remotes/origin/*" -c fetch.prune=true fetch

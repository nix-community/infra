set -eux

export GIT_SSH_COMMAND="ssh -i $RFC39_RECORD_SSH_KEY"
export GIT_AUTHOR_NAME="rfc39"
export GIT_AUTHOR_EMAIL="rfc39@nix-community"
export GIT_COMMITTER_NAME="rfc39"
export GIT_COMMITTER_EMAIL="rfc39@nix-community"

recordsdir=$HOME/rfc39-record
if ! [[ -e $recordsdir ]]; then
  git clone git@github.com:nix-community/rfc39-record.git "$recordsdir"
fi
cd "$recordsdir"
git fetch origin --no-auto-maintenance
git checkout main
git reset --hard origin/main
git maintenance run --auto

repos=(
  "home-manager all-maintainers.nix 13467276"
  "nixvim generated/all-maintainers.nix 13503498"
  "stylix generated/all-maintainers.nix 13054517"
)

for r in "${repos[@]}"; do
  read -r REPO MAINTAINER_LIST TEAM <<<"$r"

  DIR=$HOME/$REPO

  if ! [[ -e $DIR ]]; then
    git clone "https://github.com/nix-community/$REPO.git" "$DIR"
  fi
  cd "$DIR"
  git fetch origin --no-auto-maintenance
  git checkout origin/HEAD
  git maintenance run --auto

  rfc39 \
    --credentials "$RFC39_CREDENTIALS" \
    --maintainers "$MAINTAINER_LIST" \
    sync-team nix-community "$TEAM" \
    --limit 10 \
    --invited-list "$recordsdir/$REPO-invitations"
done

cd "$recordsdir"

if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Automated team sync results."
  git push origin main
fi

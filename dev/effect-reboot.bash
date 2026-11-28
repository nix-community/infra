current_outpaths=$(curl -fLs "https://nixbot.nix-community.org/nix-outputs/github/nix-community/infra/master/checks.x86_64-linux.outpaths")

while IFS= read -r host; do
  current=$(jq -r --arg host "$host" '.[$host]' "$current_outpaths")
  # shellcheck disable=SC2154
  incoming=$(jq -r --arg host "$host" '.[$host] // empty' "$incoming_outpaths")

  if [[ -z $incoming ]]; then
    echo "missing $host in outpaths" >&2
    continue
  fi

  diff -u "$current/switch-inhibitors" "$incoming/switch-inhibitors" >>reboot || [[ $? -eq 1 ]]
done < <(jq -r 'keys[]' "$current_outpaths")

# shellcheck disable=SC2034
GH_TOKEN=$(jq -r '.git.data.token' "$HERCULES_CI_SECRETS_JSON")

pr=$(jq -r '.pullRequest.number' "$NIXBOT_EVENT_JSON")

previous=$(
  gh api \
    "repos/{owner}/{repo}/issues/$pr/comments" \
    --paginate \
    --jq '.[] | select(.body | contains("infra-reboot")) | .id'
)

if [[ -s reboot ]]; then
  gh pr edit "$pr" --add-label reboot
  {
    echo '```diff'
    cat reboot
    echo '```'
  } | nixbot-pr-comment --replace-marker infra-reboot
elif [[ -n $previous ]]; then
  gh pr edit "$pr" --remove-label reboot
  echo 'no reboot' | nixbot-pr-comment --replace-marker infra-reboot
fi

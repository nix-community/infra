# https://git.lix.systems/the-distro/infra/commit/15a684c5d7e1ee25cdd6f2941ed17c01aa107781
''
  nix-env --delete-generations 1d --profile /nix/var/nix/profiles/system
  while : ; do
    used=$(($(stat -f --format="100-(100*%a/%b)" /)))
    if [[ $used -gt "85" ]]; then
      nix-store --gc --max-freed 100G
    else
      break
    fi
  done
''

flake=$(nix flake metadata self --json | jq -r '.path' | sed -e 's|/nix/store/||' -e 's|-source||')
nix_version="$(nix store ping --store daemon --json | jq -r '.version')"
case "$(uname -s)" in
Darwin)
  os_version="$(/usr/bin/sw_vers --productVersion)_$(/usr/bin/sw_vers --buildVersion)"
  ;;
Linux)
  os_version="$(uname -r)"
  if [[ -e /run/systemd/shutdown/scheduled ]]; then
    flake=reboot
  fi
  ;;
esac
system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
echo "host,flake=$flake,nix_version=$nix_version,os_version=$os_version,system=$system info=1"

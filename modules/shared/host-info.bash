flake=$(nix registry list | grep 'flake:self' | cut -d ':' -f3 | sed -e 's|/nix/store/||' -e 's|-source||')
nix_version="$(nix store ping --store daemon --json | jq -r '.version')"
case "$(uname -s)" in
Darwin)
  os_version="$(/usr/bin/sw_vers --productVersion)_$(/usr/bin/sw_vers --buildVersion)"
  ;;
Linux)
  os_version="$(uname -r)"
  ;;
esac
system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
echo "host,flake=$flake,nix_version=$nix_version,os_version=$os_version,system=$system info=1"

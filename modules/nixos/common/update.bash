arch=$(uname -m)
hostname=$(uname -n)
p=$(curl -L https://buildbot.nix-community.org/nix-outputs/nix-community/infra/master/"$arch"-linux.host-"$hostname")

cancel_reboot() {
  if [[ -e /run/systemd/shutdown/scheduled ]]; then
    shutdown -c
    kexec --unload
  fi
}

if [[ "$(readlink /run/current-system)" == "$p" ]]; then
  cancel_reboot
  exit 0
fi

nix-store --option narinfo-cache-negative-ttl 0 --realise "$p"
nix-env --profile /nix/var/nix/profiles/system --set "$p"

booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules} && cat /run/booted-system/kernel-params)"
built="$(readlink "$p"/{initrd,kernel,kernel-modules} && cat "$p"/kernel-params)"
if [[ $booted != "$built" ]]; then
  /nix/var/nix/profiles/system/bin/switch-to-configuration boot
  # don't use kexec if system is virtualized, reboots are fast enough
  if ! systemd-detect-virt -q; then
    kexec --load "$p"/kernel --initrd="$p"/initrd --append="$(cat "$p"/kernel-params) init=$p/init"
  fi
  if [[ ! -e /run/systemd/shutdown/scheduled ]]; then
    shutdown -r "+$(shuf -i 5-60 -n 1)"
  fi
else
  cancel_reboot
  /nix/var/nix/profiles/system/bin/switch-to-configuration switch
fi

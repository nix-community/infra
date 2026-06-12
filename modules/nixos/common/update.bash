arch=$(uname -m)
hostname=$(uname -n)
p=$(curl -L https://nixbot.nix-community.org/nix-outputs/github/nix-community/infra/master/"$arch"-linux.host-"$hostname")

export NIXOS_REBUILD_NO_SYSTEMD_RUN=1

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

if ! "$p"/check-switch-inhibitors; then
  nixos-rebuild boot --no-reexec --store-path "$p"
  # don't use kexec if system is virtualized, reboots are fast enough
  if ! systemd-detect-virt -q; then
    kexec --load "$p"/kernel --initrd="$p"/initrd --append="$(cat "$p"/kernel-params) init=$p/init"
  fi
  if [[ ! -e /run/systemd/shutdown/scheduled ]]; then
    shutdown -r "+$(shuf -i 5-60 -n 1)"
  fi
else
  cancel_reboot
  nixos-rebuild switch --no-reexec --store-path "$p"
fi

arch=$(uname -m)
hostname=$(uname -n)
p=$(curl -L https://buildbot.nix-community.org/nix-outputs/nix-community/infra/master/"$arch"-linux.host-"$hostname")

if [[ "$(readlink /run/current-system)" == "$p" ]]; then
  exit 0
fi

nix-store \
  --option narinfo-cache-negative-ttl 0 \
  --add-root /run/inbound-system \
  --realise "$p"

booted="$(
  readlink /run/booted-system/{initrd,kernel,kernel-modules} &&
    cat /run/booted-system/kernel-params
)"

inbound="$(
  readlink /run/inbound-system/{initrd,kernel,kernel-modules} &&
    cat /run/inbound-system/kernel-params
)"

if [[ $booted != "$inbound" ]]; then
  echo "--- diff to current-system"
  nvd diff /run/current-system /run/inbound-system
  echo "---"
  /run/inbound-system/bin/apply boot
  # don't use kexec if system is virtualized, reboots are fast enough
  if ! systemd-detect-virt -q; then
    kexec \
      --load /run/inbound-system/kernel \
      --initrd=/run/inbound-system/initrd \
      --append="$(cat /run/inbound-system/kernel-params) init=/run/inbound-system/init"
  fi
  if [[ ! -e /run/systemd/shutdown/scheduled ]]; then
    shutdown -r "+$(shuf -i 5-60 -n 1)"
  fi
else
  /run/inbound-system/bin/apply switch
fi

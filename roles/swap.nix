# https://github.com/zfsonlinux/pkg-zfs/wiki/HOWTO-use-a-zvol-as-a-swap-device
# zfs create -V 16G -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always -o primarycache=metadata -o com.sun:auto-snapshot=false zroot/swap
# mkswap -f /dev/zvol/zroot/swap
{
  swapDevices = [{ device = "/dev/zvol/zroot/swap"; }];
}

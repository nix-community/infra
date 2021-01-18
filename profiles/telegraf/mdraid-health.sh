#!/usr/bin/env bash
#
# telegraf plugin for mdstat monitoring
#
# output fields:
# - measurement: mdstat
# - tags:
#   - host: hostname
#   - dev: md device name (md0, md1 etc)
# - fields:
#   - mismatch_cnt: number of mismatched sectors during latest check
#   - state: clear / inactive / suspended / readonly / read-auto / clean / active / write-pending / active-idle
#   - active_disks: number of active disks in array
#   - degraded_disks: number of faulty disks in array (0 = healthy)
#   - total_disks: number of disks in array
#
# see https://www.kernel.org/doc/html/v4.15/admin-guide/md.html for more
#
# state values:
# - clear:         no devices, no size, no level
# - inactive:      may have some settings, but array is not active all IO results in error
# - suspended:     all IO requests will block. the array can be reconfigured.
# - readonly:      no resync can happen. no superblocks get written. Write requests fail
# - read-auto:     like readonly, but behaves like clean on a write request.
# - clean:         no pending writes, but otherwise active.
# - active:        fully active: IO and resync can be happening. when written to inactive array, starts with resync
# - write-pending: clean, but writes are blocked waiting for active to be written.
# - active-idle:   like active, but no writes have been seen for a while
#
#
# sample /proc/mdstat
#
# Personalities : [raid1] [linear] [multipath] [raid0] [raid6] [raid5] [raid4] [raid10] 
# md2 : active raid1 sdb3[1] sda3[0]
#       1936079936 blocks super 1.2 [2/2] [UU]
#       bitmap: 2/15 pages [8KB], 65536KB chunk
#
# md1 : active raid1 sdb2[1] sda2[0]
#       523712 blocks super 1.2 [2/2] [UU]
#
# md0 : active raid1 sdb1[1] sda1[0]
#       16760832 blocks super 1.2 [2/2] [UU]
#
# sample /sys/block/md0/uevent
#
# MAJOR=9
# MINOR=0
# DEVNAME=md0
# DEVTYPE=disk

HOST=$(< /proc/sys/kernel/hostname)

for MD_SYS_FOLDER in /sys/block/md*; do
  eval $(< "${MD_SYS_FOLDER}/uevent")
  
  MD_DEV=${DEVNAME}
  [ -z "${MD_DEV}" ] && continue
  	        
  MISMATCH_CNT=$(< "${MD_SYS_FOLDER}/md/mismatch_cnt")
  STATE=$(< "${MD_SYS_FOLDER}/md/array_state")
  DEGRADED_DISKS=$(< "${MD_SYS_FOLDER}/md/degraded")
  TOTAL_DISKS=$(< "${MD_SYS_FOLDER}/md/raid_disks")
  ACTIVE_DISKS=$(expr $TOTAL_DISKS - $DEGRADED_DISKS)
  
  echo "mdstat,host=${HOST},dev=${MD_DEV} mismatch_cnt=${MISMATCH_CNT}i,state=\"${STATE}\",active_disks=${ACTIVE_DISKS}i,degraded_disks=${DEGRADED_DISKS}i,total_disks=${TOTAL_DISKS}i"
done

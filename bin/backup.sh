#!/bin/sh
set -x
scsiadd -s
partprobe
#lvcreate --snapshot --size 50G --name bunkerRootSnapshot /dev/bunkerStore/bunkerRoot
cryptsetup luksOpen /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0  backup
mount -o user_xattr /dev/mapper/backup /mnt/backup
ionice -c 3 rsync --delete --inplace -aAvx /      /mnt/backup/mountpoints/slash --exclude=/var/spool/squid3/
ionice -c 3 rsync --delete --inplace -aAvx /boot/ /mnt/backup/mountpoints/boot
umount /mnt/backup
cryptsetup luksClose  backup
sync
sdparm --command=sync  /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0
sdparm --command=stop  /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0
sdparm --command=eject /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0

#!/bin/bash
set -xe
cryptsetup luksOpen /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0  backup-01 || cryptsetup luksOpen /dev/disk/by-uuid/88710eaa-55b0-4070-bd26-c182d2d075f3  backup-01
#vgscan 
#vgchange --activate y   backup-01
mount -o user_xattr /dev/mapper/backup-01 /mnt/backup
ionice -c 3 rsync --delete --delete-excluded --inplace --no-whole-file -aAvx /      /mnt/backup/mountpoints/slash --exclude=".snapshot/" --exclude=/var/spool/squid3/ --exclude=srv/backups/timemachine/ --exclude=/srv/video/Film --exclude=/srv/video/TV
ionice -c 3 rsync --delete --inplace --no-whole-file -aAvx /boot/ /mnt/backup/mountpoints/boot  --exclude=".snapshot/"
umount /mnt/backup
lvchange -a n backup-01
cryptsetup luksClose  backup
sync
sdparm --command=sync  /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0
sdparm --command=stop  /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0
sdparm --command=eject /dev/disk/by-uuid/13571e34-f219-43b5-9dc2-bb3ad519e5a0

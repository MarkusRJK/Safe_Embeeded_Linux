#!/bin/sh
#
# If a read-only root filesystem is overlayed with a temporary 
# filesystem, any installation goes into the temporary. 
# This script informs the user and allows to switch over to
# rw root filesystem.

(df | grep -q "mnt/root-ro") || exit 0
(df | grep -q "mnt/root-rw") || exit 0
(df | grep -q "aufs"       ) || exit 0

echo
echo "NOTE: This OS is running on a read-only root FS."
echo "      Any installations will be lost."
echo
echo "Do you wish to REBOOT to a writable root FS for"
echo -n "installations (y/N)?"

read reply

if [ $reply != 'y' -a $reply != 'Y' ]; then
    exit 0
fi

rootRO=/mnt/root-ro

sudo mount -o remount,rw $rootRO

if [ -e $rootRO/do-not-disable-root-ro ]; then
    sudo mv $rootRO/do-not-disable-root-ro $rootRO/disable-root-ro 
else
    sudo touch $rootRO/disable-root-ro 
fi

sudo /sbin/reboot

exit 0

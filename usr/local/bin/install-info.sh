#!/bin/sh
#
# If a read-only root filesystem is overlayed with a temporary 
# filesystem, any installation goes into the temporary. 
# This script informs the user and allows to switch over to
# rw root filesystem.

rootRO=/mnt/root-ro

(df | grep -q "$rootRO"    ) || exit 0
(df | grep -q "mnt/root-rw") || exit 0
(df | grep -q "aufs"       ) || exit 0

echo
echo "NOTE: You are trying to modify the root FS."
echo "      You are currently running on a"
echo "      read-only root FS."
echo "      Any installations would be lost."
echo
echo "Do you wish to REBOOT to a writable root FS for"
echo -n "installations (yes/N)? "

read reply

if [ $reply != 'yes' -a $reply != 'YES' ]; then
    echo "Answer 'yes' or 'YES' to continue - try again"
    exit 0
fi

if [ -d $rootRO ]; then
    sudo mount -o remount,rw $rootRO
else
    exit 0
fi

if [ -e $rootRO/do-not-disable-root-ro ]; then
    sudo mv $rootRO/do-not-disable-root-ro $rootRO/disable-root-ro 
else
    sudo touch $rootRO/disable-root-ro 
fi

sudo /sbin/reboot

exit 0

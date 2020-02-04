#!/bin/bash
set -x
WORKDIR="$ROOT_DIR/isowork"

sudo umount $WORKDIR/minimal/src/minimal_rootfs/boot
sudo umount $WORKDIR/minimal/src/minimal_rootfs/dev/pts

sudo umount $WORKDIR/minimal/src/minimal_rootfs/dev/
sudo umount $WORKDIR/minimal/src/minimal_rootfs/sys/
sudo umount $WORKDIR/minimal/src/minimal_rootfs/proc/

#


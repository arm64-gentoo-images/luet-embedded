#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

wget https://downloads.raspberrypi.org/raspbian_lite/archive/2019-09-30-15:24/root.tar.xz -O /rootfs.tar.xz
mkdir /temp && cd /temp && tar -xJf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/temp/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /temp/ /
rm -rf /temp

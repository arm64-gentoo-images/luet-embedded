#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

wget https://build.funtoo.org/1.4-release-std/arm-32bit/raspi3/2020-01-03/stage3-raspi3-1.4-release-std-2020-01-03.tar.xz -O /rootfs.tar.xz
mkdir /temp && cd /temp && tar -xJf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/temp/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /temp/ /
rm -rf /temp

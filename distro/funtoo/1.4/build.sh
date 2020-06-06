#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

FUNTOO_RELEASE="1.4"
DATE_VERSION=${DATE_VERSION:-$(echo "${PACKAGE_VERSION}" | cut -d'+' -f 2)}

wget https://build.funtoo.org/${FUNTOO_RELEASE}-release-std/arm-32bit/raspi3/${DATE_VERSION}/stage3-raspi3-${FUNTOO_RELEASE}-release-std-${DATE_VERSION}.tar.xz -O /rootfs.tar.xz

mkdir /temp && cd /temp && tar -xJf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz
rsync -A -a --delete --numeric-ids --recursive -d -H --one-file-system --xattrs --exclude '/temp/*'  --exclude '/etc/resolv.conf'  --exclude '/etc/hostname'  --exclude '/sys/' --exclude '/etc/hosts'  --exclude '/sys/*' --exclude '/proc/*' --exclude '/dev/pts/*' /temp/ /
rm -rf /temp

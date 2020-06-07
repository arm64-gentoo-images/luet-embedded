#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

FUNTOO_RELEASE="1.4"
DATE_VERSION=$(echo "${PACKAGE_VERSION}" | cut -d'+' -f 2)
DATE_VERSION=${DATE_VERSION//./-}

FUNTOO_URL=https://build.funtoo.org/${FUNTOO_RELEASE}-release-std
FUNTOO_ARCH=arm-32bit

wget ${FUNTOO_URL}/${FUNTOO_ARCH}/raspi3/${DATE_VERSION}/stage3-raspi3-${FUNTOO_RELEASE}-release-std-${DATE_VERSION}.tar.xz -O /rootfs.tar.xz

mkdir /temp
cd /temp && tar -xJf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz

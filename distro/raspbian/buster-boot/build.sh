#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

wget https://downloads.raspberrypi.org/raspbian_lite/archive/2019-09-30-15:24/boot.tar.xz -O /boot.tar.xz
mkdir /boot || true

cd /boot 
tar -xJf /boot.tar.xz --xattrs --numeric-owner
rm /boot.tar.xz

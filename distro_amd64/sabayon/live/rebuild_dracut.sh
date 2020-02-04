#!/bin/bash
set -ex
kver=$(cat /etc/kernels/**/RELEASE_LEVEL)
karch=$(uname -m)
dracut -N -a dmsquash-live -a pollcdrom -a systemd -a systemd-initrd -a systemd-networkd -a plymouth -a dracut-systemd --force --kver=${kver} /boot/initramfs-genkernel-${karch}-${kver}
#!/bin/bash

sudo umount workdir/boot
sudo umount workdir/root/dev/pts
sudo umount workdir/root/dev
sudo umount workdir/root/proc
sudo umount workdir/root/sys
sudo umount workdir/root
sudo rm -rfv workdir
#!/bin/bash

# https://github.com/Tomas-M/linux-live.git
# http://minimal.linux-bg.org/#home

IMAGE_NAME="${IMAGE_NAME:-luet_os.img}"
LUET_PACKAGES="${LUET_PACKAGES:-}"
LUET_BIN="${LUET_BIN:-../luet}"
LUET_CONFIG="${LUET_CONFIG:-../conf/luet.yaml}"
WORKDIR="$ROOT_DIR/isowork"
ML_CHECKOUT="${ML_CHECKOUT:-c0b5af7258be1c2650c4207e7dd4794aa45ebca6}"
mkdir -p $WORKDIR

[ ! -d "$WORKDIR/minimal" ] && git clone https://github.com/ivandavidov/minimal.git $WORKDIR/minimal

pushd $WORKDIR/minimal
git checkout "${ML_CHECKOUT}" || true
popd
pushd $WORKDIR/minimal/src

# We skip kernel compilation and rootfs preparation. We are going to use luet for that
# We also skip docker image generation, everything is built by Docker already.
rm -rfv 01* 02* 03* 04* 05* 06* 07* 08* 09* 11* 15*

# Point to our kernel/rootfs
cat <<'EOF' > 09_prepare.sh
#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

echo "**** Copy kernel"
# Prepare the kernel install area.
echo "Removing old kernel artifacts. This may take a while."
rm -rf $KERNEL_INSTALLED
mkdir -p $KERNEL_INSTALLED



if [[ -L "$SRC_DIR/minimal_boot/bzImage" ]]
then
# Install the kernel file.
cp $(readlink -f $SRC_DIR/minimal_boot/bzImage) \
  $KERNEL_INSTALLED/kernel
else 
cp $SRC_DIR/minimal_boot/bzImage \
  $KERNEL_INSTALLED/kernel
fi
echo "*** GENERATE ROOTFS BEGIN ***"


echo "Preparing rootfs work area. This may take a while."
mkdir -p $ROOTFS

# Copy all rootfs resources to the location of our 'rootfs' folder.
cp -r $SRC_DIR/minimal_rootfs/* $ROOTFS
EOF
chmod +x 09_prepare.sh
set -ex

# Get calculation right
sed -i '/image_size=$((kernel_size + rootfs_size + loader_size + 65536))/c\image_size=$((kernel_size + rootfs_size*2 + loader_size + 65536))' 13_prepare_iso.sh

pushd minimal_rootfs

mkdir -p boot
mount --bind $WORKDIR/minimal/src/minimal_boot boot
mkdir -p var/lock
mkdir -p run/lock
mkdir -p var/cache/luet
mkdir -p etc/luet
mkdir -p dev
mkdir -p sys
mkdir -p proc
mkdir -p tmp
mkdir -p dev/pts
cp -rfv "${LUET_CONFIG}" etc/luet/.luet.yaml
cp -rfv "${LUET_BIN}" luet
sudo mount --bind /dev $WORKDIR/minimal/src/minimal_rootfs/dev/
sudo mount --bind /sys $WORKDIR/minimal/src/minimal_rootfs/sys/
sudo mount --bind /proc $WORKDIR/minimal/src/minimal_rootfs/proc/
sudo mount --bind /dev/pts $WORKDIR/minimal/src/minimal_rootfs/dev/pts

sudo chroot . /luet --nolock=true install $LUET_PACKAGES

# Cleanup/umount
sudo rm -rf luet

set +e
sudo umount $WORKDIR/minimal/src/minimal_rootfs/boot
sudo umount $WORKDIR/minimal/src/minimal_rootfs/dev/pts

sudo umount $WORKDIR/minimal/src/minimal_rootfs/dev/
sudo umount $WORKDIR/minimal/src/minimal_rootfs/sys/
sudo umount $WORKDIR/minimal/src/minimal_rootfs/proc/

rm -rfv tmp/*

popd

set -e
# UEFI too
sed -i 's/FIRMWARE_TYPE=bios/FIRMWARE_TYPE=both/g' .config
bash build_minimal_linux_live.sh

#!/bin/bash

# https://github.com/Tomas-M/linux-live.git
# http://minimal.linux-bg.org/#home

IMAGE_NAME="${IMAGE_NAME:-luet_os.img}"
LUET_PACKAGES="${LUET_PACKAGES:-}"
LUET_BIN="${LUET_BIN:-../luet}"
LUET_CONFIG="${LUET_CONFIG:-../conf/luet-local.yaml}"
WORKDIR="$ROOT_DIR/isowork"
OVERLAY="${OVERLAY:-false}"
ML_CHECKOUT="${ML_CHECKOUT:-c0b5af7258be1c2650c4207e7dd4794aa45ebca6}"
mkdir -p $WORKDIR

FIRST_STAGE="${FIRST_STAGE:-distro/seed}"
[ ! -d "$WORKDIR/minimal" ] && git clone https://github.com/ivandavidov/minimal.git $WORKDIR/minimal

pushd $WORKDIR/minimal
git checkout "${ML_CHECKOUT}" || true
popd
pushd $WORKDIR/minimal/src

rm -rf "$WORKDIR/minimal/src/minimal_rootfs/"
mkdir -p "$WORKDIR/minimal/src/minimal_rootfs/"

echo "Initial root:"
ls -liah  "$WORKDIR/minimal/src/minimal_rootfs/"


rm -rf "$WORKDIR/minimal/src/minimal_boot/"
mkdir -p "$WORKDIR/minimal/src/minimal_boot/"

echo "Initial boot:"
ls -liah  "$WORKDIR/minimal/src/minimal_boot/"

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

if [[ "$OVERLAY" == true ]]; then

cat <<'EOF' > 11_overlay.sh

#!/bin/sh

set -e

# Load common properties and functions in the current script.
. ./common.sh

echo "*** GENERATE OVERLAY BEGIN ***"

# Remove the old ISO image overlay area.
echo "Removing old overlay area. This may take a while."
rm -rf $ISOIMAGE_OVERLAY

# Create the new ISO image overlay area.
mkdir -p $ISOIMAGE_OVERLAY
cd $ISOIMAGE_OVERLAY

# Read the 'OVERLAY_TYPE' property from '.config'
OVERLAY_TYPE=`read_property OVERLAY_TYPE`

# Read the 'OVERLAY_LOCATION' property from '.config'
OVERLAY_LOCATION=`read_property OVERLAY_LOCATION`
echo "Overlay: $OVERLAY_ROOTFS $OVERLAY_LOCATION $OVERLAY_TYPE"
export OVERLAY_TYPE=sparse
mkdir -p $OVERLAY_ROOTFS
touch $OVERLAY_ROOTFS/.keep
ls -liah $OVERLAY_ROOTFS
if [ "$OVERLAY_LOCATION" = "iso" ] && \
   [ "$OVERLAY_TYPE" = "sparse" ] && \
   [ -d $OVERLAY_ROOTFS ] && \
   [ ! "`ls -A $OVERLAY_ROOTFS`" = "" ] && \
   [ "$(id -u)" = "0" ] ; then

  # Use sparse file as storage place. The above check guarantees that the whole
  # script is executed with root permissions or otherwise this block is skipped.
  # All files and folders located in the folder 'minimal_overlay' will be merged
  # with the root folder on boot.

  echo "Using sparse file for overlay."

  # This is the Busybox executable that we have already generated.
  BUSYBOX=$ROOTFS/bin/busybox

  # Create sparse image file with 3MB size. Note that this increases the ISO
  # image size.
  truncate -s 3G $ISOIMAGE_OVERLAY/minimal.img

  # Find available loop device.
  LOOP_DEVICE=$(losetup -f)

  # Associate the available loop device with the sparse image file.
  losetup $LOOP_DEVICE $ISOIMAGE_OVERLAY/minimal.img

  # Format the sparse image file with Ext2 file system.
  mkfs.ext2 $LOOP_DEVICE

  # Mount the sparse file in folder 'sparse".
  mkdir $ISOIMAGE_OVERLAY/sparse
  mount $ISOIMAGE_OVERLAY/minimal.img sparse

  # Create the overlay folders.
  mkdir -p $ISOIMAGE_OVERLAY/sparse/rootfs
  mkdir -p $ISOIMAGE_OVERLAY/sparse/work

  cp -r $SRC_DIR/minimal_overlay/rootfs/* \
    $ISOIMAGE_OVERLAY/sparse/rootfs

  # Unmount the sparse file and delete the temporary folder.
  sync
  umount $ISOIMAGE_OVERLAY/sparse
  sync
  sleep 1
  rm -rf $ISOIMAGE_OVERLAY/sparse

  # Detach the loop device since we no longer need it.
  losetup -d $LOOP_DEVICE
elif [ "$OVERLAY_LOCATION" = "iso" ] && \
     [ "$OVERLAY_TYPE" = "folder" ] && \
     [ -d $OVERLAY_ROOTFS ] && \
     [ ! "`ls -A $OVERLAY_ROOTFS`" = "" ] ; then

  # Use normal folder structure for overlay. All files and folders located in
  # the folder 'minimal_overlay' will be merged with the root folder on boot.

  echo "Using folder structure for overlay."

  # Create the overlay folders.
  mkdir -p $ISOIMAGE_OVERLAY/minimal/rootfs
  mkdir -p $ISOIMAGE_OVERLAY/minimal/work

  cp -r $SRC_DIR/minimal_overlay/rootfs/* \
    $ISOIMAGE_OVERLAY/minimal/rootfs
else
  echo "The ISO image will have no overlay structure."
fi

cd $SRC_DIR

echo "*** GENERATE OVERLAY END ***"
EOF
chmod +x 11_overlay.sh
fi
set -ex

# Get calculation right
#sed -i '/image_size=$((kernel_size + rootfs_size + loader_size + 65536))/c\image_size=$((kernel_size + rootfs_size*2 + loader_size + 65536))' 13_prepare_iso.sh



umount_rootfs() {
  local rootfs=$1
  sudo umount -l $rootfs/boot
  sudo umount -l $rootfs/dev/pts

  sudo umount -l $rootfs/dev/
  sudo umount -l $rootfs/sys/
  sudo umount -l $rootfs/proc/
}

luet_install() {

  local rootfs=$1
  local packages="$2"

  ## Initial rootfs
  pushd "$rootfs"
  mkdir -p boot
  mount --bind $WORKDIR/minimal/src/minimal_boot boot
  mkdir -p var/lock
  mkdir -p run/lock
  mkdir -p var/cache/luet
  mkdir -p var/luet
  mkdir -p etc/luet
  mkdir -p dev
  mkdir -p sys
  mkdir -p proc
  mkdir -p tmp
  mkdir -p dev/pts
  cp -rfv "${LUET_CONFIG}" etc/luet/.luet.yaml
  cp -rfv "${LUET_BIN}" luet
  sudo mount --bind /dev $rootfs/dev/
  sudo mount --bind /sys $rootfs/sys/
  sudo mount --bind /proc $rootfs/proc/
  sudo mount --bind /dev/pts $rootfs/dev/pts

  sudo chroot . /luet --nolock=true install ${packages}
      # Cleanup/umount
  umount_rootfs $rootfs || true

  sudo rm -rf luet
  popd

}

trap cleanup 1 2 3 6

cleanup()
{
   umount_rootfs  "$WORKDIR/minimal/src/minimal_rootfs"
   umount_rootfs  "$WORKDIR/minimal/src/minimal_overlay/rootfs"
}


if [[ "$OVERLAY" == true ]]; then
echo "Building overlay"
luet_install "$WORKDIR/minimal/src/minimal_rootfs" "${FIRST_STAGE}"
luet_install "$WORKDIR/minimal/src/minimal_overlay/rootfs" "${LUET_PACKAGES}" || true
else

luet_install "$WORKDIR/minimal/src/minimal_rootfs" "${LUET_PACKAGES}" || true
fi
set -e
# UEFI too
sed -i 's/FIRMWARE_TYPE=bios/FIRMWARE_TYPE=both/g' .config
sed -i 's/OVERLAY_TYPE=folder/OVERLAY_TYPE=sparse/g' .config


bash build_minimal_linux_live.sh

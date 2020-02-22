# luet-embedded

A PoC of a luet-based OS for ARM and amd64 based devices.

## Prerequisites

- Arm board / Amd64 (depending on what you want to build)
- Docker
- luet installed (+container-diff) in `/usr/bin/luet` (arm build)
- make

## ARM

### Build the packages

    sudo make build-all

While to rebuild, after doing changes, just do: `sudo make rebuild-all`

### Create the repository

    sudo make create-repo

### Serve the repo locally

    make serve-repo

### Create the flashable image

#### Funtoo based system

    sudo LUET_PACKAGES='distro/funtoo-rpi-meta-0.1' make image

#### Raspbian based system

    sudo LUET_PACKAGES='distro/raspbian-rpi-meta-0.1' make image

## AMD64

Same as before, just export the tree before running the commands:

### Building packages

    sudo TREE=distro_amd64 make build-all

Rebuilding:

    sudo TREE=distro_amd64 make rebuild-all
    sudo CLEAN=true TREE=distro_amd64 make rebuild-all # Overwrites and recompile all packages forcefully

Create repo:

    make TREE=distro_amd64 create-repo

To build the iso, we need to serve the package repository locally, so they can be installed in the chrooted environment:

    make serve-repo

Start the iso build process:

    sudo OVERLAY=true FIRST_STAGE="distro/sabayon-initramfs" LUET_PACKAGES="flavor/sabayon-minimal-live system/luet-develop system/container-diff" make iso

## How does it work

With overlay enabled, Luet will compose 4 different rootfs needed to create an ISO from the specfile in `distro_amd64`: initramfs, isoimage, uefi and rootfs.

As luet is a static binary, it doesn't need any special setup to compose your images.

You can specify which packages (whose defintions are in `distro_amd64`) Luet should install in the layers, by any degree of freedom.

- `LUET_PACKAGES`: space-separated list of packages to install in the rootfs which is booted
- `FIRST_STAGE`: space-separated list of packages to install in the initramfs which is used to boot the rootfs
- `ISOIMAGE_PACKAGES`: space-separated list of packages to install in the isoimage. You can use it to supply additional files to the xorriso process
- `UEFI_PACKAGES`: space-separated list of packages to install in the uefi image. Is the efi image to boot uefi systems
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

    sudo LUET_PACKAGES="system/lml-init system/lml-boot distro/sabayon-live system/luet-develop system/container-diff" make iso

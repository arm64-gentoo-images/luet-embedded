# luet-embedded

A PoC of a luet-based OS for ARM devices.

## Prerequisites

- Arm board
- Docker
- luet installed (+container-diff) in `/usr/bin/luet` (arm build)
- make

## Build the packages

    sudo make build-all

While to rebuild, after doing changes, just do: `sudo make rebuild-all`

## Create the repository

    sudo make create-repo

## Serve the repo locally

    make serve-repo

## Create the flashable image

### Funtoo based system

    sudo LUET_PACKAGES='distro/funtoo-1.4 distro/raspbian-boot-0.20191208 system/luet-develop-0.5' make image

### Raspbian based system

    sudo LUET_PACKAGES='distro/raspbian-0.20191208 distro/raspbian-boot-0.20191208 system/luet-develop-0.5' make image


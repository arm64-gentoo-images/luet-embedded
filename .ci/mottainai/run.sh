#!/bin/bash
set -ex

IMAGE_NAME="${IMAGE_NAME:-luet_os}"
PACKAGES="${PACKAGES:-flavor/sabayon-minimal-x-live}"
WORKDIR="${WORKDIR:-$ROOT_DIR/.ci/mottainai/}"

mottainai-cli task compile $WORKDIR/build_iso.tmpl -s "ImageName=${IMAGE_NAME}" -s "Packages=${PACKAGES}" -o $WORKDIR/task.yaml
cat $WORKDIR/task.yaml
mottainai-cli task create --yaml $WORKDIR/task.yaml "$@"
rm -rf $WORKDIR/task.yaml
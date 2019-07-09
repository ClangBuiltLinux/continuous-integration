#!/usr/bin/env bash
# Takes the architecture as a parameter
# Currently supported values: arm64

# Make sure we don't have any unset variables
set -u

# Download latest buildroot release
BUILDROOT_VERSION=2019.02.3
if [[ -d src ]]; then
    cd src || exit 1
    if [[ $(git describe --exact-match --tags HEAD) != "${BUILDROOT_VERSION}" ]]; then
        git fetch origin ${BUILDROOT_VERSION}
        git checkout ${BUILDROOT_VERSION}
    fi

    # Clean up artifacts from the last build
    make clean
else
    git clone -b ${BUILDROOT_VERSION} git://git.busybox.net/buildroot src
    cd src || exit 1
fi

# Use the config in the parent folder
CONFIG=../${1}.config
if [[ ! -f ${CONFIG} ]]; then
    echo "${CONFIG} does not exist! Is your parameter correct?"
    exit 1
fi
BR2_DEFCONFIG=${CONFIG} make defconfig
if [[ -n ${EDITCONFIG:-} ]]; then
    make menuconfig
    make savedefconfig
fi

# Build images
make -j"$(nproc)"

# Make sure images folder exists
IMAGES_FOLDER=../../images/${1}
[[ ! -d ${IMAGES_FOLDER} ]] && mkdir -p "${IMAGES_FOLDER}"

# Copy new images
# Make sure images exist before moving them
IMAGES=( "output/images/rootfs.cpio" "output/images/rootfs.ext4" )
for IMAGE in "${IMAGES[@]}"; do
    if [[ ! -f ${IMAGE} ]]; then
        echo "${IMAGE} could not be found! Did the build error?"
        exit 1
    fi
    cp -v "${IMAGE}" "${IMAGES_FOLDER}"
done

#!/usr/bin/env bash
# Takes the architecture as a parameter
# Currently supported values: arm64

# Make sure we don't have any unset variables
set -u

# Clean up
rm -rf build
mkdir -p build

# Download latest buildroot release
curl https://buildroot.org/downloads/buildroot-2018.08.2.tar.gz | tar -xzf - -C build --strip-components=1
cd build || exit 1

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

# Init files
mkdir -p overlays/etc/init.d
cp ../overlays/S50yolo overlays/etc/init.d
cp ../overlays/inittab overlays/etc

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

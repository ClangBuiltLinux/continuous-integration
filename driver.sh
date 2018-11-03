#!/usr/bin/env bash

set -u

setup_variables() {
  while [[ ${#} -ge 1 ]]; do
    case ${1} in
      "-c"|"--clean") cleanup=true ;;
      "-h"|"--help")
        echo
        echo " Usage: ./driver.sh <options>"
        echo
        echo " Script description: Build a Linux kernel image with Clang and boot it"
        echo
        echo " Environment variables:"
        echo "   The script can take into account specific environment variables, mostly used with Travis."
        echo "   They can be invoked either via 'export VAR=<value>; ./driver.sh' OR 'VAR=value ./driver.sh'"
        echo
        echo "   ARCH:"
        echo "       If no ARCH value is specified, arm64 is the default. Currently, arm and arm64 are supported."
        echo
        echo " Optional parameters:"
        echo "   -c | --clean:"
        echo "       Run 'make mrproper' before building the kernel. Normally, the build system is smart enought to figure out"
        echo "       what needs to be rebuilt but sometimes it might be necessary to clean it manually."
        echo
        exit 0 ;;
    esac

    shift
  done

  # Turn on debug mode after parameters in case -h was specified
  set -x

  # arm64 is the current default if nothing is specified
  [[ -z "${ARCH:-}" ]] && ARCH=arm64
  export ARCH
  case ${ARCH} in
    "arm")
      config=multi_v7_defconfig
      image_name=zImage
      qemu="qemu-system-arm"
      qemu_cmdline=( -drive "file=images/arm/rootfs.ext4,format=raw,id=rootfs,if=none"
                     -device "virtio-blk-device,drive=rootfs"
                     -append "console=ttyAMA0 root=/dev/vda" )
      export CROSS_COMPILE=arm-linux-gnueabi- ;;

    "arm64")
      config=defconfig
      image_name=Image.gz
      qemu="qemu-system-aarch64"
      qemu_cmdline=( -cpu cortex-a57
                     -drive "file=images/arm64/rootfs.ext4,format=raw"
                     -append "console=ttyAMA0 root=/dev/vda" )
      export CROSS_COMPILE=aarch64-linux-gnu- ;;

    # Unknown arch, error out
    *)
      echo "Unknown ARCH specified!"
      exit 1 ;;
  esac
}

check_dependencies() {
  set -e

  command -v nproc
  command -v gcc
  command -v "${CROSS_COMPILE:-}"as
  command -v "${CROSS_COMPILE:-}"ld
  command -v ${qemu}
  command -v timeout
  command -v unbuffer
  command -v clang-8

  set +e
}

mako_reactor() {
  make -j"$(nproc)" CC="${ccache} ${clang}" HOSTCC="${ccache} ${clang}" "${@}"
}

build_linux() {
  local ccache clang
  ccache=$(command -v ccache)
  clang=$(command -v clang-8)

  if [[ ! -d linux ]]; then
    git clone --depth=1 git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    cd linux
  else
    cd linux
    git fetch --depth=1 origin master
    git reset --hard origin/master
  fi
  # Only clean up old artifacts if requested, the Linux build system
  # is good about figuring out what needs to be rebuilt
  [[ -n "${cleanup:-}" ]] && mako_reactor mrproper
  mako_reactor ${config}
  mako_reactor ${image_name}
  cd "${OLDPWD}"
}

boot_qemu() {
  local kernel_image=linux/arch/${ARCH}/boot/${image_name}
  # for the rest of the script, particularly qemu
  set -e
  test -e ${kernel_image}
  timeout 1m unbuffer ${qemu} \
    -machine virt \
    "${qemu_cmdline[@]}" \
    -m 512 \
    -nographic \
    -kernel ${kernel_image}
}

setup_variables "${@}"
check_dependencies
build_linux
boot_qemu

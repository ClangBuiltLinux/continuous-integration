set -ux

check_dependencies() {
  set -e

  test -x `which gcc`
  test -x `which aarch64-linux-gnu-as`
  test -x `which aarch64-linux-gnu-ld`
  test -x `which qemu-system-aarch64`
  test -x `which timeout`
  test -x `which unbuffer`
  test -x `which clang-8`

  set +e
}

build_clang() {
  ln -sf ../../clang llvm/tools/clang
  mkdir -p llvm/build
  cd llvm/build

  cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
  ninja clang

  cd -
  rm llvm/tools/clang
}

build_linux() {
  local clang=$(which clang-8)

  cd linux
  export ARCH=arm64
  export CROSS_COMPILE=aarch64-linux-gnu-
  # TODO: do we really want to be building the kernel from scratch every time?
  # Rerunning ninja above will not rebuild unless source files change.
  #make CC=$clang mrproper
  make CC=$clang defconfig
  make CC=$clang -j`nproc`
  cd -
}

build_root() {
  if [[ ! -d buildroot ]]; then
    wget https://buildroot.org/downloads/buildroot-2018.08.tar.gz
    tar -xzf buildroot-2018.08.tar.gz
    mv buildroot-2018.08 buildroot
    rm -rf buildroot-2018.08.tar.gz
  fi

  if [[ ! -e buildroot/output/images/rootfs.ext4 ]]; then
    mkdir -p buildroot/overlays/etc/init.d/
    cp -f inittab buildroot/overlays/etc/.
    cp -f S50yolo buildroot/overlays/etc/init.d/.

    cd buildroot
    make defconfig BR2_DEFCONFIG=../buildroot.config
    make -j`nproc`
    cd -
  fi
}

boot_qemu() {
  local kernel_image=linux/arch/arm64/boot/Image.gz
  local rootfs=buildroot/output/images/rootfs.ext4
  # for the rest of the script, particularly qemu
  set -e
  test -e $kernel_image
  test -e $rootfs
  timeout 1m unbuffer qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a57 \
    -m 512 \
    -nographic \
    -kernel $kernel_image \
    -hda $rootfs \
    -append "console=ttyAMA0 root=/dev/vda" \
    -no-reboot
}

check_dependencies
#build_clang
build_linux
build_root
boot_qemu

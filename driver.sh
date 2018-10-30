set -ux

check_dependencies() {
  set -e

  test -x `which cmake`
  test -x `which ninja`
  test -x `which gcc`
  test -x `which aarch64-linux-gnu-as`
  test -x `which aarch64-linux-gnu-ld`

  set +e
}

build_clang() {
  rm -f llvm/tools/clang
  ln -s ../../clang llvm/tools/clang
  mkdir -p llvm/build
  cd llvm/build

  cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
  ninja clang

  cd -
  rm llvm/tools/clang
}

build_linux() {
  local clang=$(readlink -f ./llvm/build/bin/clang)
  set -e
  test -x $clang
  set +e

  cd linux
  export ARCH=arm64
  export CROSS_COMPILE=aarch64-linux-gnu-
  make CC=$clang mrproper
  make CC=$clang defconfig
  make CC=$clang -j`nproc`
  cd -
}

check_dependencies
build_clang
build_linux

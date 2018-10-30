set -ux

check_dependencies() {
  set -e

  test -x `which cmake`
  test -x `which ninja`
  test -x `which gcc`

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

check_dependencies
build_clang

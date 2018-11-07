#!/usr/bin/env bash
# Installs all of the necessary packages in a Docker container

# Show all commands and exit upon failure
set -eux

# Install the official Debian packages that we need
# curl and wget are not installed by default so this
# is separate from the Clang/lld installation below
# because we would need to at least install curl to
# get LLVM's apt key
apt-get update -qq
apt-get install -y -qq \
    bc \
    binutils \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabi \
    bison \
    ccache \
    curl \
    expect \
    flex \
    git \
    gnupg \
    libssl-dev \
    make \
    openssl \
    qemu-system-arm \
    qemu-system-x86 \
    >/dev/null

# Install nightly verisons of Clang and lld (apt.llvm.org)
curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main" | tee -a /etc/apt/sources.list
apt-get update -qq
apt-get install -y -qq \
  clang-8 \
  lld-8 \
  >/dev/null

# By default, Travis's ccache size is around 500MB. We'll
# start with 2GB just to see how it plays out.
ccache -M 2G

# Enable compression so that we can have more objects in
# the cache (9 is most compressed, 6 is default)
ccache --set-config=compression=true
ccache --set-config=compression_level=9

# Set the cache directory to /travis/.ccache, which we've
# bind mounted during 'docker create' so that we can keep
# this cached across builds
ccache --set-config=cache_dir=/travis/.ccache

# Clear out the stats so we actually know the cache stats
ccache -z

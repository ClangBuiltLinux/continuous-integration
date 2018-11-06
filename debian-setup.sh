#!/usr/bin/env bash
# Installs all of the necessary packages in a Docker container
# MUST BE RUN WITH ROOT

# Show all commands and exit upon failure
set -eux

# Make sure that all packages are up to date
apt-get update
apt-get upgrade -y

# Install the official Debian packages that we need
# curl and wget are not installed by default so this
# is separate from the Clang/lld installation below
# because we would need to at least install curl to
# get LLVM's apt key
apt-get install -y bc \
                   binutils \
                   binutils-aarch64-linux-gnu \
                   binutils-arm-linux-gnueabi \
                   bison \
                   ccache \
                   curl \
                   flex \
                   expect \
                   git \
                   gnupg \
                   libssl-dev \
                   openssl \
                   make \
                   qemu-system-arm \
                   qemu-system-x86

# Install nightly verisons of Clang and lld (apt.llvm.org)
curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main" | tee -a /etc/apt/sources.list
apt-get update -qq
apt-get install -y clang-8 lld-8

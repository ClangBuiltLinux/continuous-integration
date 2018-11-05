#!/usr/bin/env bash
# Installs all of the necessary packages in a Docker container
# MUST BE RUN WITH ROOT

apt-get update
apt-get upgrade -y
apt-get install -y bc binutils binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi bison ccache curl flex expect gcc git gnupg libssl-dev openssl make qemu-system-arm qemu-system-x86
curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main" | tee -a /etc/apt/sources.list
apt-get update -qq
apt-get install -y clang-8 lld-8

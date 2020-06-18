# continuous-integration

A repo for daily continuous compilation and boot testing of Clang built Linux.
Uses [daily snapshots](https://apt.llvm.org/) of
[Clang](https://clang.llvm.org/), top of tree
[torvalds/linux](torvalds/linux.git), [Buildroot](https://buildroot.org/) root
filesystems, and [QEMU](https://www.qemu.org/) to boot.

[![Build Status](https://travis-ci.com/ClangBuiltLinux/continuous-integration.svg?branch=master)](https://travis-ci.com/ClangBuiltLinux/continuous-integration)

```sh
$ git clone git@github.com:ClangBuiltLinux/continuous-integration.git
$ cd continuous-integration
$ ./driver.sh
```

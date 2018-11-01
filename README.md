# continuous-integration
A directory that pulls in everything and builds everything

```sh
$ git clone -j`nproc` git@github.com:ClangBuiltLinux/continuous-integration.git
$ cd continuous-integration
$ ./driver.sh
```
By default, `driver.sh` builds an arm64 image and boots it. If you would like to build and boot an arm image, run `ARCH=arm ./driver.sh`

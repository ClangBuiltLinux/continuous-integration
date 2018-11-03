# continuous-integration
A directory that pulls in everything and builds everything

```sh
$ git clone -j`nproc` git@github.com:ClangBuiltLinux/continuous-integration.git
$ cd continuous-integration
$ ./driver.sh
```
Without any options, `driver.sh` builds an arm64 image and boots it. To learn more about the script, run `./driver.sh -h`.

#!/bin/bash

CUR_DIR=$(cd $(dirname $0); pwd)
QEMU_DIR=${CUR_DIR}/../src/qemu

pushd ${QEMU_DIR}
git clean -xdf
./configure \
    --target-list=riscv64-softmmu \
    --enable-debug-tcg \
    --enable-debug \
    --enable-debug-info \
    --enable-slirp \
    -enable-trace-backends=log
make -j`nproc`
popd
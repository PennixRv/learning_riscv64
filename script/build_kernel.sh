#!/bin/bash

export CROSS_COMPILE=riscv64-linux-gnu-
export ARCH=riscv

CUR_DIR=$(cd $(dirname $0); pwd)
LINUX_DIR=${CUR_DIR}/../src/linux

pushd ${LINUX_DIR}
make defconfig
make -j`nproc`
popd
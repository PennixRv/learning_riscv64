#!/bin/bash

export CROSS_COMPILE=riscv64-linux-gnu-
export ARCH=riscv

CUR_DIR=$(cd $(dirname $0); pwd)
UBOOT_DIR=${CUR_DIR}/../src/u-boot
OPENSBI_DIR=${CUR_DIR}/../src/opensbi

pushd ${UBOOT_DIR}
git clean -xdf
popd

pushd ${OPENSBI_DIR}
git clean -xdf
popd

pushd ${OPENSBI_DIR}
make PLATFORM=generic PLATFORM_RISCV_XLEN=64
popd

export OPENSBI=${OPENSBI_DIR}/build/platform/generic/firmware/fw_dynamic.bin

pushd ${UBOOT_DIR}
make qemu-riscv64_spl_defconfig
bear -- make -j`nproc`
popd

ln -sf ${UBOOT_DIR}/compile_commands.json .
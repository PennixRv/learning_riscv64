#!/bin/bash

export CROSS_COMPILE=riscv64-linux-gnu-
export ARCH=riscv

CUR_DIR=$(cd $(dirname $0); pwd)
UBOOT_DIR=${CUR_DIR}/../src/u-boot
OPENSBI_DIR=${CUR_DIR}/../src/opensbi

pushd ${OPENSBI_DIR}
make PLATFORM=generic FW_PAYLOAD_PATH=${UBOOT_DIR}/u-boot.bin
popd

pushd ${UBOOT_DIR}
make qemu-riscv64_smode_defconfig
make -j`nproc`
popd

export OPENSBI=${OPENSBI_DIR}/build/platform/generic/firmware/fw_dynamic.bin

pushd ${UBOOT_DIR}
make qemu-riscv64_spl_defconfig
make -j`nproc`
popd

#!/bin/bash

CUR_DIR=$(cd $(dirname $0); pwd)
QEMU_DIR=${CUR_DIR}/../src/qemu
UBOOT_DIR=${CUR_DIR}/../src/u-boot
LINUX_DIR=${CUR_DIR}/../src/linux
OPENSBI_DIR=${CUR_DIR}/../src/opensbi


pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

# ${QEMU_DIR}/build/qemu-system-riscv64 \
#     -M virt \
#     -smp 4 \
#     -m 4G \
#     -display none \
#     -serial stdio \
#     -bios ${UBOOT_DIR}/spl/u-boot-spl \
#     -device loader,file=${UBOOT_DIR}/u-boot.itb,addr=0x80200000

${QEMU_DIR}/build/qemu-system-riscv64 \
    -M virt \
    -smp 4 \
    -m 4G \
    -display none \
    -serial stdio \
    -bios ${OPENSBI_DIR}/build/platform/generic/firmware/fw_jump.bin \
    -kernel ${UBOOT_DIR}/u-boot.bin


# ${QEMU_DIR}/build/qemu-system-riscv64 \
#     -M virt \
#     -smp 4 \
#     -m 4G \
#     -display none \
#     -serial stdio \
#     -bios ${OPENSBI_DIR}/build/platform/generic/firmware/fw_payload.elf

# ${QEMU_DIR}/build/qemu-system-riscv64 \
#     -M virt \
#     -smp 4 \
#     -m 4G \
#     -nographic \
#     -bios ${OPENSBI_DIR}/build/platform/generic/firmware/fw_jump.bin \
#     -kernel ${LINUX_DIR}/arch/riscv/boot/Image  \
#     -append "root=/dev/vda rw console=ttyS0"

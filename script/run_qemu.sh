#!/bin/bash

CUR_DIR=$(cd $(dirname $0); pwd)
QEMU_DIR=${CUR_DIR}/../src/qemu
UBOOT_DIR=${CUR_DIR}/../src/u-boot
LINUX_DIR=${CUR_DIR}/../src/linux
OPENSBI_DIR=${CUR_DIR}/../src/opensbi

GDB=

if [ $# == 1 ] && [ $1 == "gdb" ]
then
    GDB+="-gdb tcp::4567 -S"
fi

LOG=
#LOG+="-d in_asm,op,guest_errors,unimp -D ./qemu_log_`date +%Y%m%d%H%M`.log"
#LOG+="-d guest_errors -D ./qemu_log_`date +%Y%m%d%H%M`.log"

${QEMU_DIR}/build/qemu-system-riscv64 \
    -M virt \
    -smp 4 \
    -m 4G \
    -display none \
    -serial stdio \
    -bios ${UBOOT_DIR}/spl/u-boot-spl.bin \
    -device loader,file=${UBOOT_DIR}/u-boot.itb,addr=0x80200000 ${GDB} ${LOG}

# ${QEMU_DIR}/build/qemu-system-riscv64 \
#     -M virt \
#     -smp 4 \
#     -m 4G \
#     -display none \
#     -serial stdio \
#     -bios ${OPENSBI_DIR}/build/platform/generic/firmware/fw_jump.bin \
#     -kernel ${UBOOT_DIR}/u-boot.bin

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

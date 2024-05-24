#!/bin/bash

# 使用 bear 来生成 compile_commands.json
if ! command -v bear &> /dev/null
then
    echo "bear command could not be found"
    if [[-f /etc/os-release]]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "Run'sudo apt-get install bear'to install bear."
                ;;
            centos|fedora|rhel)
                echo "Run'sudo yum install bear'to install bear."
                ;;
            arch|manjaro)
                echo "Run'sudo pacman -S bear'to install bear."
                ;;
            *)
                echo "Please check your package manager to install bear."
                ;;
        esac
    else
        echo "Cannot determine the OS distribution, please install bear manually."
    fi
    exit 1
fi

# 使用 jq 来合并生成的 compile_commands.json
if ! command -v jq &> /dev/null
then
    echo "jq command could not be found"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "Run'sudo apt-get install jq'to install jq."
                ;;
            centos|fedora|rhel)
                echo "Run'sudo yum install jq'to install jq."
                ;;
            arch|manjaro)
                echo "Run'sudo pacman -S jq'to install jq."
                ;;
            *)
                echo "Please check your package manager to install jq."
                ;;
        esac
    else
        echo "Cannot determine the OS distribution, please install jq manually."
    fi
    exit 1
else
    echo "jq command is available."
fi

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

# dynamic：从上一级 Boot Stage 获取下一级 Boot Stage 的入口信息，以 struct fw_dynamic_info 结构体通过 a2 寄存器传递
# jump：假设下一级 Boot Stage Entry 为固定地址，直接跳转过去运行
# payload：在 jump 的基础上，直接打包进来下一级 Boot Stage 的 Binary
pushd ${OPENSBI_DIR}
bear -- make PLATFORM=generic PLATFORM_RISCV_XLEN=64
popd

# 用于在构建 U-boot 时 将 fw_dynamic.bin 固件打包进包含 u-boot.bin 的 FIT 镜像中
export OPENSBI=${OPENSBI_DIR}/build/platform/generic/firmware/fw_dynamic.bin

# 将生成 u-boot-spl.bin 镜像和包含 fw-dynamic.bin + u-boot.bin 的 u-boot.itb 镜像
# 二者分别位于 ${UBOOT_DIR}/spl/u-boot-spl.bin 和 ${UBOOT_DIR}/u-boot.itb
# 从配置 CONFIG_SPL_LOAD_FIT_ADDRESS=0x80200000 可知 u-boot-spl.bin 最终将在地址 0x80200000 处解析 FIT 镜像并跳转到 OpenSBI 的地址
# 在 Qemu 中 通过 -device loader,file=${UBOOT_DIR}/u-boot.itb,addr=0x80200000 参数 将生成的 FIT 镜像加载到指定的位置 0x80200000
pushd ${UBOOT_DIR}
make qemu-riscv64_spl_defconfig
bear -- make -j`nproc`
popd

# 清理之前生成的镜像
git clean -xdf

genimage --config ${UBOOT_DIR}/board/sifive/unleashed/genimage_spi-nor.cfg --inputpath ${UBOOT_DIR}

jq -s 'add' ${UBOOT_DIR}/compile_commands.json ${OPENSBI_DIR}/compile_commands.json > compile_commands.json
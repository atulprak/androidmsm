#!/bin/bash
# Purpose: Script for building AOSP code and Linux kernel for walleye using open-source toolchains. 
# Author: atulp@google.com
# License: Gnu GPL
# License is same as Linux kernel license, since the code
# helps compile the Linux kernel for the device)
# Change these directory paths to point to your aosp and NDK folders.
export AOSP=~/src/aosp 
export CROSS_COMPILE=~/ndk/android-ndk-r16b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-
# Change these if you are building for something other than walleye (Pixel 2) as needed.
export KERNELNAME=wahoo
export TARGETBUILD=walleye
export ARCH=arm64
export SUBARCH=arm64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CLANG_PREBUILT_BIN=$AOSP/prebuilts/clang/host/linux-x86/clang-4053586/bin
export CC_CMD=${CLANG_PREBUILT_BIN}/clang

# These likely would not have to be changed.
export PATH=$PATH:$AOSP/prebuilts/misc/linux-x86/dtc:$AOSP/prebuilts/misc/linux-x86/libufdt

build_aosp()
{
    set -x
    cp arch/arm64/boot/dtbo.img $AOSP/device/google/${KERNELNAME}-kernel 
    cp arch/arm64/boot/Image.lz4-dtb $AOSP/device/google/${KERNELNAME}-kernel
    set +x
    # Uncomment if other drivers need to be also updated. The following paths are specific to walleye and may need
    # changes for your specific device.
    cp drivers/input/touchscreen/stm/*.ko $AOSP/device/google/${KERNELNAME}-kernel
    cp drivers/power/*.ko $AOSP/device/google/wahoo-kernel
    cp drivers/input/touchscreen/synaptics_dsx_htc/*.ko $AOSP/device/google/${KERNELNAME}-kernel
    cp drivers/input/touchscreen/lge/*.ko $AOSP/device/google/${KERNELNAME}-kernel
    cp drivers/input/touchscreen/lge/lgsic/*.ko $AOSP/device/google/${KERNELNAME}-kernel
     

    echo "Running lunch and make for ${TARGETBUILD}-userdebug in the $AOSP folder"
    pushd .
    cd $AOSP  || return 1
    . build/envsetup.sh || return 1
    lunch aosp_${TARGETBUILD}-userdebug || return 1
    # Alternative 1: Builds everything
    make -j48 || return 1
    # Alternative 2: The following may work if only the kernel is being updated
    # make bootimage
    popd
    return 0
}

flash_image()
{
    echo "Attempting to flash image..."
    pushd .
    cd $AOSP
    . build/envsetup.sh
    lunch aosp_${TARGETBUILD}-userdebug || return 1
    set -x
    adb reboot bootloader || return 1
    sleep 10
    echo "fastboot flashall -w"
    fastboot flashall -w || return 1
    set +x
    popd
    echo "Attempt to flash image done..."
}

# Make walleye_defconfig or appropriate kernel configuration file
set -x
echo "Building kernel: make ${KERNELNAME}_defconfig"
make ${KERNELNAME}_defconfig


# Build the kernel, using clang if needed.
if [ -z "${CC_CMD}" ];
then
    echo "Building kernel: make V=1 -j40"
    make V=1 -j40 || exit 1
else
    echo "Building kernel: make V=1 CC=${CC_CMD} -j40"
    make V=1 CC=${CC_CMD} -j40 || exit 1
fi
set +x

# Copy the kernel files to the AOSP tree and build it.
build_aosp || exit 1

# Flash the image to the connected device over adb. The device must be authorized for adb.
flash_image || exit 1



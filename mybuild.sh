#!/bin/bash
AOSP=~/src/aosp 

export CROSS_COMPILE=~/ndk/android-ndk-r15c/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android- 
export ARCH=arm64
export TARGET_PREBUILT_KERNEL=~/src/msm/arch/arm64/boot/Image.lz4-dtb

make marlin_defconfig

# I also edited the following files:
# $AOSP/out/target/product/marlin/system/build.prop
# and $AOSP/out/target/product/marlin/system/etc/default.prop
# Both files should contain the following lines (not sure if mtp is necessary):
# persist.service.adb.enable=1
# persist.service.debuggable=1
# persist.sys.usb.config=mtp,adb


build_aosp()
{
    cp arch/arm64/boot/Image.lz4-dtb $AOSP/device/google/marlin-kernel || return 1;
    pushd .
    cd $AOSP  || return 1
    . build/envsetup.sh || return 1
    lunch aosp_marlin-userdebug || return 1
    # The following command may be needed the first time
    # make -j48 || return 1
    make bootimage
    popd
    return 0
}

try_fastboot_flashall()
{
    echo "fastboot flashall -w"
    fastboot flashall -w || return 1;
}

try_fastboot()
{
    echo "fastboot flash boot boot.img"
    fastboot flash boot  boot.img || return 1;
    fastboot reboot || return 1
    sleep 15
}

try_adbreboot() {
   echo "adb reboot-bootloader"
    timeout 20 adb reboot-bootloader
    sleep 10
    try_fastboot
    # echo "fastboot reboot"
    # timeout 20 fastboot reboot
    # adb push ~/.android/adbkey.pub /data/misc/adb/adb_keys
    # timeout 20 adb reboot
}


flash_image()
{
    pushd .
    cd $AOSP/out/target/product/marlin || return 1
    try_adbreboot
    popd
}


make V=1 -j40 && build_aosp && flash_image


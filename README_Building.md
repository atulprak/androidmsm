<h2>Building and installing a custom kernel from public sources on Pixel 2 ("walleye")</h2>

Atul Prakash

One can find instructions for building from Android Open Source for various devices [here](https://source.android.com/setup/building).  Nevertheless, these instructions can be helpful if you are building a custom kernel for the newer phones such as Pixel 2, as some of the steps differ from what worked for Pixel phones in details. The instructions consist of three parts: (1) Updating the bootloader and baseband firmware; (2) Making sure that AOSP builds and works to create a working baseline with a prebuilt kernel; and (3) Building an unmodified kernel from sources and making sure that works to create another working baseline. Once (3) is accomplished, then it should be straightforward to customize that kernel. The first two steps are similar to those for devices such as Pixel. Step (3) differs in several ways from Pixel. 

<h2>Update to the latest Bootloader and baseband firmware</h2>




1.  To update the device's bootloader and baseband firmware to a recent version, install the latest good factory images. They are available at: [https://developers.google.com/android/images](https://developers.google.com/android/images) for the device.  For example, for a Pixel 2 (walleye),  the current latest version as of early Feb. 2018 is 8.1.0 (Build 4503492, OPM1.171019.019, Feb. 2018). 
1.  Make sure this boots. [Enable developer mode and turn on USB debugging.](https://developer.android.com/studio/debug/dev-options.html) 

This step creates a first working baseline.

<h2>Build from AOSP and test</h2>




1.  Get AOSP's release for your device for the same version that boots successfully from factory images or from flashstation. See this [table](https://source.android.com/setup/build-numbers#source-code-tags-and-builds) to select the version number for your device. Follow the general instructions at: [https://source.android.com/setup/downloading](https://source.android.com/setup/downloading). For example, for Pixel 2, we can select the android-8.1.0_r12 version, which corresponds to the OPM1.171019.019 build.
    1.  `repo init -u https://android.googlesource.com/platform/manifest -b android-8.1.0_r12
`
1.  Get the appropriate drivers from [https://developers.google.com/android/drivers](https://developers.google.com/android/drivers):
    1.  For the example version, you want the Pixel 2 binaries for Android 8.1.0 (OPM1.171019.019).
1.  Unpack the drivers in the aosp folder and run the resulting shell script files.
1.  In the aosp folder: execute (change the lunch argument to whatever is appropriate for your device)

    ```
    	 source build/envsetup.sh

                lunch aosp_walleye-userdebug
                make -j40
                adb reboot bootloader
                fastboot flashall -w
    ```


Make sure the system boots fine and you can get adb access with root. This step helps create a second working baseline.

<h2>Build Linux Kernel</h2>


Fetch the kernel sources for your kernel. For example, for the Pixel 2, use the **wahoo** kernel. Also, unlike kernels for older devices, Pixel 2 requires the kernel to be compiled with clang, causing some differences in the build process.



1.  git clone [https://android.googlesource.com/kernel/msm](https://android.googlesource.com/kernel/msm)
1.  git checkout -b android-msm-wahoo-4.4-oreo-mr1 origin/android-msm-wahoo-4.4-oreo-mr1 

        (Change the release as needed to another wahoo release. You can find the kernel branches at: [https://android.googlesource.com/kernel/msm/+refs](https://android.googlesource.com/kernel/msm/+refs))

To compile the Linux kernel for your device (the example script below is for Pixel 2), save and execute the following script from $KERNELDIR, the folder where kernel source was downloaded. Modify the script to suit your system. The script builds the kernel image, copies it to AOSP tree, builds new images for flashing, and then flashes the images to the connected Pixel 2 device (which is assumed to have adb or fastboot access via USB enabled). The script may be a big time saver. If the script does not work for you, then it can be helpful to copy-and-paste the commands and execute them in a shell one by one to help debug. 

If all goes well, you should be running the freshly compiled kernel and your pixel 2 device should boot fine. If it does not boot, it can be helpful to checkout the kernel messages to troubleshoot. See below. If your kernel works, you have a third baseline. 

If you get an error at adb or fastboot such as "waiting for device", you need to make sure that "adb devices"  lists the device and re-run the script. The script assumes that there is only one device connected via adb. If the device boots into recovery mode, try rebooting the device to see if the device boots correctly.

You can now modify the kernel sources, if you like, and use the above script to install it on your device. It can be helpful to create a new git branch when modifying the kernel so that you can quickly fallback to your original, working kernel in case something goes wrong. For example, from your kernel tree, you can do:

To see your current branch, use:

```
git branch
```


To create a new branch to modify the kernel files. Choose an appropriate branch name.


```
git branch -b new-branch-name
```


You can switch branches by doing the following, where <code><em>branchname</em></code> is one of the branches shown by <code>git branch</code>.


```
git checkout branchname
```


<h3>Seeing the kernel debug messages
</h3>


It may be helpful to adb into the device, become root, and issue the following:

```
dmesg -n 8
```
This turns on more detailed debug messages --- those that are printed by pr_debug. Then, use available ways to see kernel messages for the Linux Kernel and Android.


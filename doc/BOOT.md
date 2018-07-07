# Boot Process in Depth
The overall boot RPi boot process has been described over and over again. You can form an idea by looking [here](https://raspberrypi.stackexchange.com/questions/10442/what-is-the-boot-sequence), [here](https://wiki.beyondlogic.org/index.php?title=Understanding_RaspberryPi_Boot_Process) or [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/bootflow.md)

This part specifically talks about how CattlePi works within the boot context and not about the whole boot process.

 * The **initfs** image contains the initramfs and the kernel is instructed via options both in config.txt (initramfs cattleinit.cpio followkernel) and cmdline.txt (initrd=-1) to load and start the initramfs. 
 * Once it starts, it will run the init script within the initramfs. The init script will invoke all the logic needed. It will:
 * [Download the configuration](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L116) associated with the device from <endpoint>/boot/<device_id>/config
 * [Download the images](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L130) specified in the config
 * [Update the boot partition if needed](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L152)
 * It will [build the root filesystem](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L166)
 * Finally it will swap to using the built root filesystem (this happens right at the end of init where control is given to the init specified in the rootfs - usually systemd for Raspbian).

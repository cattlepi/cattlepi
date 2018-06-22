# CattlePi
We've all heard about and want to treat out servers as [cattle and not pets](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/). The goal of this project is to help you do just that. 

**What does this mean exactly?** Several things, including but not limited to:
 * ability to run a RPi headless, without the need to physically interact with the device 
 * ability to update the software running on the Pi over the wire (and keep it up to date)
 * ability to run your software in an evironment that closely mirrors the normal RPi Linux environment
 * as less state on the device itself as possible (ideally zero)
 * minimize the possible failure scenarios. In 99.9% of the cases the solution should just be a reboot

## How does it work?
This repository provides the tooling and wiring needed to build/generate 2 filesystem images. We're going to refer to these 2 images as the **initfs** image and the **rootfs** image.  
The **initfs** image needs to be written onto a FAT partition for the SDCard that is going to be used with your RPi. This partition is the one used by the RPi in the boot process to read the kernel, various hardware configuration parameters and modules.  
Baked within the initramfs image that ships with **initfs** there are scripts that download and apply the latest **initfs** and **rootfs** images and build the final root filesystem that will be used by your RPi.  
The boot process uses an external API endpoint to retrieve the configuration associated with your RPi and to figure out where the image files are located.  

## Quickstart
To quickly get going, you can use a prebuild **initfs** image that you can find [here](http://cattlepi.com/initfs).  
This image uses the following API endpoint: https://api.cattlepi.com  
The image also used the following API key: **deadbeef**  
Starting with an empty SD cards, format it to contain one FAT partion and write the image to the FAT partition. Insert the card into the RPi and watch it boot.

## Tooling Used
Following [main pieces of software] are used: 
 * [Ansible](https://docs.ansible.com/ansible/latest/index.html) - the workhorse of the builder process. To be able to build the images you're going to need a physical RPi. The ansible playbooks need to be configured to use this.
 * [initramfs-tools](https://manpages.debian.org/jessie/initramfs-tools/initramfs-tools.8.en.html) to build the initramfs ramdisk image that will be used. You can learn more about it [here](https://www.kernel.org/doc/Documentation/early-userspace/README) and [here](https://archive.is/20130104033427/http://www.linuxfordevices.com/c/a/Linux-For-Devices-Articles/Introducing-initramfs-a-new-model-for-initial-RAM-disks/)
 * [unionfs-fuse](http://manpages.ubuntu.com/manpages/trusty/man8/unionfs-fuse.8.html) - the final root filesystem is an [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) [union](https://en.wikipedia.org/wiki/UnionFS) filesystem. The union has 2 layers: bottom, read-only one mounted with the **rootfs** image and a top, copy-on-write, read/write **tmpfs** 
 * [squashfs-tools](http://tldp.org/HOWTO/SquashFS-HOWTO/index.html) - used for the bottom layer of the root union filesystem. SquashFs is a compressed, readonly FS. 

## Boot Process in Depth
This section specifically talks about how CattlePi works within the boot context and not about the whole boot process. See the *RPi Boot Process in General* section for pointers on how the whole process works.

 * The **initfs** will contains the initramfs and the kernel is instructed via options both in config.txt (initramfs cattleinit.cpio followkernel) and cmdline.txt (initrd=-1) to load and start the initramfs. 
 * Once it starts, it will run the init script within the initramfs. The init script will invoke all the logic needed. It will:
 * [Download the configuration](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L116) associated with the device from <endpoint>/boot/<device_id>/config
 * [Download the images](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L130) specified in the config
 * [Update the boot partition if needed](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L152)
 * It will [build the root filesystem](https://github.com/cattlepi/cattlepi/blob/2168b9a0ca742d87dd63b6c8ca13dcd6b2254b44/builder/resources/usr/share/initramfs-tools/scripts/cattlepi-base/helpers#L166)
 * Finally it will swap to using the built root filesystem (happens right at the end of init where control is given to the init specified in the rootfs - usually systemd for raspbian)

## RPi Boot Process in General
The overall boot process has been described over and over again. You can form an idea by looking [here](https://raspberrypi.stackexchange.com/questions/10442/what-is-the-boot-sequence), [here](https://wiki.beyondlogic.org/index.php?title=Understanding_RaspberryPi_Boot_Process) or [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/bootflow.md)

# Building and Testing the Images Locally
You will need: 
 * one Raspberry Pi (preferably 3B+)
 * a Linux based system (a Mac should work but was not tested on)
 * patience (the whole build process can take quite a while)

```bash
The process is a bit involved but pretty straighforward and reproducible once you get the hang of it. If you get stuck or have questions do reach out at hello@cattlepi.com
```

**step 1 - clone the latest CattlePi version**  
```bash
git clone git@github.com:cattlepi/cattlepi.git
cd cattlepi/
```

**step 2 - ensure that you have python installed**  
```bash
python --version
```
Install for your own OS version/flavor if you don't have python installed.  

**step 3 - ensure you have virtualenv installed**  
```bash
virtualenv --version
```
Install for your own OS version/flavor if you don't have virtualenv installed.  

**step 4 - build the virtual environment you're going to use**  
From within the cattlepi dir run:
```bash
bin/build.sh tools_setup
```

**step 5 - download the latest RASPBIAN STRETCH LITE**   
You can find it here: [https://downloads.raspberrypi.org/raspbian_lite_latest](https://downloads.raspberrypi.org/raspbian_lite_latest)

**step 6 - write the latest raspian to the SD card**  
You can use something like [Etcher](https://etcher.io/) for a painless, quick operation

**step 7 - enable ssh**  
On the /boot partition for the sdcard, create an empty file named ssh. Also [see here](https://www.raspberrypi.org/documentation/remote-access/ssh/), method 3

**step 8 - Boot up the Raspberry Pi**  
Insert the SD card into the Raspberry Pi
The Pi needs to have a physical ethernet connection. 
It also needs to be on the same network as your development machine.
Boot the Pi and learn its IP Address (this can be by looking at your router, using nmap, or connecting it to an external display - whichever works for you).
Let's assume the the IP of the PI is 192.168.1.12

**step 9 - Copy your SSH key to the PI**  
```bash
ssh pi@192.168.1.12 "mkdir -p ~/.ssh/"
cat ~/.ssh/id_rsa.pub | (ssh pi@192.168.1.12 "cat >> ~/.ssh/authorized_keys")
```
Make sure you swap out the IP with your own ip. Also, make sure that you have a valid public key for your development machine. If not you will need to generate one.

The default password for the pi user on raspian is **raspberry**  
Test that the passwordless interaction with your builder Pi now works
```bash
ssh pi@192.168.1.12 whoami
```
The previous command should not longer prompt you for a password

**step 10 - update the hosts file with your configurations**  
In the cattlepi directory, the **builder/hosts** file
Swap out your PI IP in the builder nodes configuration.
replace the api endpoint with http://192.168.1.166:4567 where 192.168.1.166 is the IP of your development machine.

In the cattlepi directory, the **server/bin/run_server.sh** file
Put your development machine ip in the SERVERIP export (same as above, e.g. 192.168.1.166)

**step 11 - build the images**  
In the cattlepi directory, run
```bash
bin/build.sh
```
This will take anywhere between 15-40 minutes (depends on the speed of your internet connection for package downloads - as an example: when this was written and tested it took: 0:13:15.352). You can follow along in builder/stages.yaml to see all the operations that are invoked as part of the ansible playbook that builds the images.  
The build process will output 2 images in **builder/output**: initramfs.tgz is the **initfs** and rootfs.sqsh is the **rootfs**.  
You can and are actually encouraged to open up the files and look around. 

**step 12 - copy the initfs on [another] SD card**  
Usually it's recommanded to have a 2nd SD card and 2nd RPi to not have to go through all the setup steps for the builder Pi every time you want to build the image (the builder used /tmp on the builder Pi, so reusing the builder should be doable). That being said, you can use the same SD card / same Pi if you want (or you can use 1 Pi w/ 2 cards - just be sure to properly shutdown the PIs)

Create a FAT partition and uncompress the contents of builder/output/initramfs.tgz onto the partition. You can do this manually or you can try using the following
```bash
bin/build.sh tools_copy_initfs_to_sdcard
```
Do keep in mind that using the script makes the assumption that the FAT partition is at /dev/mmcblk0p1 and that you don't have anything at /mnt/SD (so it may not work for you and you'll need to do this manually)

**step 13 - start the local server which will be used to server the images**  
```bash
bin/build.sh tools_run_local_api
```

**step 14 - insert the SD card into the RPi and boot it up**  
The Pi should boot and you should see it downloading the image files and the configuration, applying it and switching to the root filestystem that it has built.



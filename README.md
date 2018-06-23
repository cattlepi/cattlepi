# CattlePi
We've all heard about and want to treat out servers as [cattle and not pets](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/). The goal of this project is to help you do just that. 

**What does this mean?** Several things, including but not limited to:
 * ability to run a RPi headless, without the need to physically interact with the device 
 * ability to update the software running on the Pi over the wire (and keep it up to date)
 * ability to run your software in an evironment that closely mirrors the normal RPi Linux environment
 * as less state on the device itself as possible (ideally zero)
 * minimize the possible failure scenarios. In 99.9% of the cases the solution should just be a reboot

## How does it work?
A image is written onto an SD card partition that will be used to start the Raspberry Pi (RPi). This image (refered to as the **initfs** image) contains code to both self-update and to download the final root filesystem (refered to as the **rootfs**) the RPi is going to use. 

The boot code communicates with with an external API endpoint to retrieve the configuration associated with your RPi and to figure out where the image files are located and download them (i.e. both the boot image and the rootfs image can freely change between boots).

As an optimization, the images are cached onto the SD card boot partition to make subsequent boots faster (and to avoid the download network traffic if not needed)

## What does this repository contain?
This repository provides the tooling and wiring needed to build/generate the images used to boot and the root filesystem. 

To build and test images locally, [follow this guide](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md)

A little more detail on the boot process can be [found here](https://github.com/cattlepi/cattlepi/blob/master/doc/BOOT.md)

## Quickstart
To quickly get going, you can use a prebuild **initfs** image that you can find [here](http://cattlepi.com/initfs).  

This image uses the following API endpoint: https://api.cattlepi.com   
The image uses the following API key: **deadbeef**   

Starting with an empty SD cards, format it to contain one FAT partion and write the image to the FAT partition. Insert the card into the RPi and watch it boot.

## Tooling Used
Following [main pieces of software] are used: 
 * [Ansible](https://docs.ansible.com/ansible/latest/index.html) - the workhorse of the builder process. To be able to build the images you're going to need a physical RPi. The ansible playbooks need to be configured to use this.
 * [initramfs-tools](https://manpages.debian.org/jessie/initramfs-tools/initramfs-tools.8.en.html) to build the initramfs ramdisk image that will be used. You can learn more about it [here](https://www.kernel.org/doc/Documentation/early-userspace/README) and [here](https://archive.is/20130104033427/http://www.linuxfordevices.com/c/a/Linux-For-Devices-Articles/Introducing-initramfs-a-new-model-for-initial-RAM-disks/)
 * [unionfs-fuse](http://manpages.ubuntu.com/manpages/trusty/man8/unionfs-fuse.8.html) - the final root filesystem is an [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) [union](https://en.wikipedia.org/wiki/UnionFS) filesystem. The union has 2 layers: bottom, read-only one mounted with the **rootfs** image and a top, copy-on-write, read/write **tmpfs** 
 * [squashfs-tools](http://tldp.org/HOWTO/SquashFS-HOWTO/index.html) - used for the bottom layer of the root union filesystem. SquashFs is a compressed, readonly FS. 
 
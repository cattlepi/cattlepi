# CattlePi
A lot of Raspberry Pi projects treat their software and hardware as pets. A lot of time is put into configuring and tweaking the setup. If the hardware dies or the SD card wears out it can be very challenging or time consuming to rebuild/replicate the setup. Normally this is fine for a single DIY and/or educational project. But it's hardly scalable. 

This goal of the project is to automate seting up and running multiple Raspberry Pi nodes, with intelligent fail-safe and fallback mechanisms. We want to turn your pet project into a cattle project. 

**What does this mean?** Several things, including but not limited to:
 * the ability to run a RPi headless, without the need to physically interact with the device 
 * the ability to update the OS and other software on the Pi over the wire (and keep it up to date)
 * the ability to run your software in an environment that closely mirrors the normal RPi Linux environment
 * minimization of state on the device (ideally zero state)
 * minimization of failure scenarios (in most cases the solution should merely require rebooting)
 * graceful fall-back mechanisms

## How does it work?
Using the builder in this project you can create and use two images: an **initfs** image and a **rootfs** image.

The (**initfs**) is written onto an SD card partition. This image contains code to both self-update and to download the final root filesystem (**rootfs**) used by the RPi. 

The boot code communicates with with an external API endpoint, to retrieve the configuration associated with your RPi, as well as to figure out where the image files are located and download them (i.e. both the boot image and the rootfs image can freely change between boots).

As an optimization, the images are cached onto the SD card boot partition to make subsequent boots faster (and to avoid any unnecessary network traffic).

## What does this repository contain?
This repository provides the tooling and wiring needed to build/generate the images used to boot and the root filesystem. 

To build and test images locally, [follow this guide](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md)

A little more detail on the boot process can be [found here](https://cattlepi.com/flow/)

Also please look at the [FAQ associated with this project](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md)

## Quickstart
To quickly get going, you can use a prebuilt **initfs** image that you can find [here](https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/v2/initramfs.tgz?apiKey=deadbeef).  

This image uses the following API endpoint: https://api.cattlepi.com and the following API key: **deadbeef**   

Starting with an empty SD card, format it to contain one FAT partion and write the image to the FAT partition. Insert the card into the RPi and watch it boot. You will get the default image that was configured and please keep in mind that **deadbeef** is a demo/shared API key. 

Learn more details about the api itself at https://cattlepi.com

## Tooling Used
The following software is used in the project: 
 * [Ansible](https://docs.ansible.com/ansible/latest/index.html) - the workhorse of the builder process. To be able to build the images you're going to need a physical RPi. The ansible playbooks need to be configured to use this.
 * [initramfs-tools](https://manpages.debian.org/jessie/initramfs-tools/initramfs-tools.8.en.html) to build the initramfs ramdisk image that will be used. You can learn more about it [here](https://www.kernel.org/doc/Documentation/early-userspace/README) and [here](https://archive.is/20130104033427/http://www.linuxfordevices.com/c/a/Linux-For-Devices-Articles/Introducing-initramfs-a-new-model-for-initial-RAM-disks/).
 * [unionfs-fuse](http://manpages.ubuntu.com/manpages/trusty/man8/unionfs-fuse.8.html) - the final root filesystem is a [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) [union](https://en.wikipedia.org/wiki/UnionFS) filesystem. The union has two layers: a bottom, read-only, one mounted with the **rootfs** image, and a top, copy-on-write, read/write **tmpfs**.
 * [squashfs-tools](http://tldp.org/HOWTO/SquashFS-HOWTO/index.html) - used for the bottom layer of the root union file system. SquashFs is a compressed, read-only file system. 


Raspberry Pi is a trademark of the [Raspberry Pi Foundation](https://www.raspberrypi.org/)
 

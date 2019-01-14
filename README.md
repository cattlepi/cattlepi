# CattlePi


[![GitHub tag](https://img.shields.io/github/tag/cattlepi/cattlepi.svg)](https://github.com/cattlepi/cattlepi)
[![GitHub](https://img.shields.io/github/license/cattlepi/cattlepi.svg)](https://github.com/cattlepi/cattlepi)

A lot of Raspberry Pi projects treat their software as pets. A lot of time is put into configuring and tweaking the setup. If the hardware dies or the SD card wears out it can be very challenging or time consuming to rebuild/replicate the software setup.  Normally this is fine for a single DIY and/or educational project. But it's hardly practical or scalable in other cases.  
Our goal is to automate both the initial setup and the update process for multiple Raspberry Pi nodes.  
We want to **turn your pet project into a cattle project**.  

**What does this mean?** Several things:  
 * the ability to run a RPi headless, without the need to physically interact with the device 
 * the ability to update the OS and other software on the Pi over the wire (and keep it up to date)
 * the ability to run your software in an environment that closely mirrors a normal Raspberry Pi Linux environment
 * minimization of state on the device (ideally zero state)
 * minimization of failure scenarios (in most cases the solution should merely require rebooting)

## Quick-start
To quickly get going, you can use a prebuilt **initfs** image that you can find [here (cattlepi.zip download)](https://api.cattlepi.com/images/global/raspbian-lite/2018-06-29/bootstrap/cattlepi.zip?apiKey=deadbeef).  
This image uses the following API endpoint: https://api.cattlepi.com and the following API key: **deadbeef**   

You can write the image to an empty SDCard using etcher: https://etcher.io/    
Several guides on etcher are available, including https://www.raspberrypi.org/documentation/installation/installing-images/ and https://www.raspberrypi.org/magpi/pi-sd-etcher/.  
The only thing that is different is that instead of using the raspbian downloaded image you will use the cattlepi image.

Insert the card into the RPi and watch it boot. On first boot the loader will update the images and will boot the default configured image (usually the latest raspbian + any package updates)   
You can learn more details about the API itself or how to get your own API key at https://cattlepi.com

## How does it work?
Using the builder in this project you can create and use two images: an **initfs** image and a **rootfs** image.  
The (**initfs**) is written on the an SD card boot partition. This image contains code to both self-update and to download the final root file system (**rootfs**) used by the RPi.  
The boot code communicates with with an external API endpoint, to retrieve the configuration associated with your RPi, as well as to figure out where the image files are located and download them (i.e. both the boot image and the rootfs image can freely change between boots).  
As an optimization, the images are cached on the SD card boot partition to make subsequent boots faster (and to avoid any unnecessary network traffic).

## What does this repository contain?
This repository provides the tooling and wiring needed to build/generate the images used to boot and the root file system.  

To build and test images locally, [follow this guide](https://github.com/cattlepi/cattlepi/blob/master/doc/BUILDING.md)   
A little more detail on the boot process can be [found here](https://cattlepi.com/flow/)  
Also please look at the [FAQ associated with this project](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md)

## Tooling Used
The following software is used in the project: 
 * [Ansible](https://docs.ansible.com/ansible/latest/index.html) - the workhorse of the builder process. To be able to build the images you're going to need a physical RPi. The Ansible play books need to be configured to use this.
 * [initramfs-tools](https://manpages.debian.org/jessie/initramfs-tools/initramfs-tools.8.en.html) to build the initramfs ramdisk image that will be used. You can learn more about it [here](https://www.kernel.org/doc/Documentation/early-userspace/README) and [here](https://archive.is/20130104033427/http://www.linuxfordevices.com/c/a/Linux-For-Devices-Articles/Introducing-initramfs-a-new-model-for-initial-RAM-disks/).
 * [unionfs-fuse](http://manpages.ubuntu.com/manpages/trusty/man8/unionfs-fuse.8.html) - the final root file system is a [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace), [union](https://en.wikipedia.org/wiki/UnionFS) file system. The union has two layers: a bottom, read-only, one mounted with the **rootfs** image, and a top, copy-on-write, read/write **tmpfs**.
 * [squashfs-tools](http://tldp.org/HOWTO/SquashFS-HOWTO/index.html) - used for the bottom layer of the root union file system. SquashFs is a compressed, read-only file system. 

## Contact
Email: hello at cattlepi dot com  
Twitter: [@cattlepi](https://twitter.com/cattlepi)  
Reddit: [/u/cattlepi](https://www.reddit.com/user/cattlepi)  

If you would like to receive update on the CattlePi project we also have a low volume, interesting stuff, mailing list: [Subscribe here](http://eepurl.com/dDcwlL)  

The project documentation companion can be found at [https://cattlepi.com/](https://cattlepi.com/)  
Raspberry Pi is a trademark of the [Raspberry Pi Foundation](https://www.raspberrypi.org/)
 

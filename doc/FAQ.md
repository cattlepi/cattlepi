# Frequently asked questions

## What types of hardware does this work on?
The default images you'll get have been tested on:
 * Raspberry Pi 3 Model B+
 * Raspberry Pi 3 Model B
 * Raspberry Pi 2 Model B

In theory it should work on any model that's compatible with the latest Raspian. Also in theory, you could build a rootfs image that only work on a certain type of hardware.

## How is this better than doing a network boot?
It's not. It's different.   

For a network boot you need to control the dhcp and tftp server on your network. You also need something like nfs to mount the root filesystem. You also need to pre-program your Pi to be able to network boot (and only Model 3B/3B+ actually can do network boot). On top of that network booting may not be very reliable in the context of a normal network (the bootloader doesn't retry if it fails the first time and TFTP has been known to not be a very reliable way of transfering things over the network).

For CattlePi, you can just plug in the Pi in a network that will give it an IP address and provides internet connectivity (it's really connectivity to the API that's driving it) and you're set. You only need this connectivity during the boot process. Usually your WiFi router will be the right place. You can plug it in and "forget about it".

## How is this better than PiNet (http://pinet.org.uk/) or PiServer?
It's not. It's different.  
With CattlePi the idea is to make the network setup as simple as possible. It also aim to make the setup and maintenance as touch-free as possible.  
For PiNet/PiServer i believe the goals are a bit different (empowering learning and exposing people to using a Pi) and the setup is definetly something that needs to be maintained / tought about over time.

## What do I do if my question is not in here?
PR to change this file to add your question and we'll do our best to answer it.
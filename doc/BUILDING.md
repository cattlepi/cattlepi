# Building and Testing the Images Locally
You will need: 
 * at least one Raspberry Pi (preferably model 3B+). Two is better — one for the builder and another to test with
 * at least one SD card 
 * a Linux-based system (a Mac _should_ work but this has not yet been tested)
 * physical access to an ethernet connection on your local network 
 * patience (the entire build process can take quite a while)


**The process is a little involved but fairly straighforward and reproducible once you get the hang of it. If you get stuck or have questions do reach out at hello@cattlepi.com**

## Step 1 - clone the latest CattlePi version
```bash
git clone git@github.com:cattlepi/cattlepi.git
cd cattlepi/
```

## Step 2 - ensure that you have python installed
```bash
python --version
```
Follow the installation instructions for your own OS version/flavor if you don't have python installed.  

## Step 3 - ensure you have virtualenv installed
```bash
virtualenv --version
```
Again, follow installation instructions for your own OS version/flavor if you don't have virtualenv installed.  

## Step 4 - ensure you have make installed
```bash
make --version
```
Again, follow installation instructions for your own OS version/flavor if you don't have make installed.  

## Step 5 - download the latest version of RASPBIAN STRETCH LITE
You can find it here: [https://downloads.raspberrypi.org/raspbian_lite_latest](https://downloads.raspberrypi.org/raspbian_lite_latest)

## Step 6 - write this latest image of Raspian to the SD card  
You can use something like [Etcher](https://etcher.io/) for a painless, quick operation

## Step 7 - enable ssh
On the **/boot** partition for the sdcard, create an empty file named ssh. Also [see here](https://www.raspberrypi.org/documentation/remote-access/ssh/), method 3

## Step 8 - Boot up the Raspberry Pi
Insert the SD card into the Raspberry Pi. 

The RPi requires:
  * a physical ethernet connection. 
  * to be on the same network as your development machine.

Power up the Pi, let it boot, and note its IP Address (this can be done by looking at your router, using nmap, or connecting it to an external display - [see the FAQ for suggestions](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md#how-do-i-get-my-rpis-ip-address) ).

For the rest of the guide let's assume the the IP of the PI is 192.168.1.12  
Please replace this with your own IP for the rest of the steps.  

## Step 9 - Copy your SSH key to the PI
```bash
ssh pi@192.168.1.12 "mkdir -p ~/.ssh/"
cat ~/.ssh/id_rsa.pub | (ssh pi@192.168.1.12 "cat >> ~/.ssh/authorized_keys")
```
Make sure you swap out the IP with your own. Also, make sure that you have a valid public key for your development machine. If not, you will need to genererate one. For complete steps [see here](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md).

The default password for the pi user on Raspian is **raspberry** (**NOTE:** it is good security policy to change this immediately, using the passwd command).  

Test that the passwordless interaction with your builder Pi now works
```bash
ssh pi@192.168.1.12 whoami
```
The previous command should no longer prompt you for a password

## Step 10 - update the configuration with your values
The default configuration values used during the build are specified in **tools/cfg/defaults**
```bash
$ cat tools/cfg/defaults 
# conditionally set the params if not set
BUILDER_NODE=${BUILDER_NODE:-192.168.1.12}
CATTLEPI_BASE=${CATTLEPI_BASE:-https://api.cattlepi.com}
CATTLEPI_APIKEY=${CATTLEPI_APIKEY:-deadbeef}
CATTLEPI_LOCALAPI=${CATTLEPI_LOCALAPI:-192.168.1.166:4567}
```

**BUILDER_NODE** is the ip of the raspberry pi you want to use in the build process (e.g. 192.168.1.12 above).  
**CATTLEPI_BASE** is the API endpoint you want to use.  
**CATTLEPI_APIKEY** is the API endpoint you want to use.  
**CATTLEPI_LOCALAPI** is the ip:port of where you will run and/or test the local api. the ip needs to be one of your local ips.  

In order to specify your own configuration parameters create a configuration file in your home directory at **~/.cattlepi/configuration**. 
You can copy the defaults file as a starting point and update the parameters as you see fit.

A note on the BUILDER_NODE=${BUILDER_NODE:-192.168.1.12} syntax. What this means is, set BUILDER_NODE to 192.168.1.12 if it's not already set. You can set the the value directly if you want. If you keep this syntax you also have the freedom to just set this environment variable in your shell and use them from there.  
Example:  
```bash
export BUILDER_NODE=192.168.1.99
export CATTLEPI_BASE=http://192.168.1.166:4567
export CATTLEPI_APIKEY=alivebeef
export CATTLEPI_LOCALAPI=192.168.1.166:4567
```

## Step 11 - build the images

In the cattlepi directory, run:
```bash
make
```
This will take anywhere between 15 - 40 minutes (depending on your internet connection for package downloads - as an example: when this was written and tested it took a little over 13 minutes). You can follow along in **templates/raspbian/stages.yml** to see all the operations that are invoked as part of the ansible playbook that builds the images.  
The build process will output two images in **builder/latest/output**: initramfs.tgz is the **initfs** and rootfs.sqsh is the **rootfs**.  
You can — and are actively encouraged to — explore these files. 

## Step 12 - copy the initfs onto [another] SD card
I recommend having a second SD card and RPi, in order to avoid the tedium of the setup process each time you want to build the image. The builder used **/tmp** on the builder Pi; you can re-use the builder if you have the same hardware. Alternatively, you can use the same SD card/RPi, or even one RPi with two SD cards (just be sure to properly shut down the RPis between swapping out the SD cards).

Create a FAT partition and uncompress the contents of builder/latest/output/initramfs.tgz onto the partition. You can do this manually, or you can try:
```bash
make copy_initfs_to_sdcard
```
Keep in mind that the script assumes that the FAT partition is at **/dev/mmcblk0p1** and that you don't have anything at **/mnt/SD**. Consequently, you may require an alternative, manual, work-around. 

## Step 13 - start the local server (used to serve the images)
```bash
make localapi_run
```
This assumes that the CATTLEPI_BASE point to the same location as CATTLEPI_LOCALAPI. If that's not the case, the Pi will boot with whatever API endpoint you have specified.

## Step 14 - insert the SD card into the RPi and boot it up
The Pi should boot and you should see it downloading the image files and the configuration, applying it and switching to the root filestystem that it has built.

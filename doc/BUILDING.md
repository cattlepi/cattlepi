# Building and Testing the Images Locally
You will need: 
 * at least one Raspberry Pi (preferably 3B+) (preferably you would have 2, one for the builder one to test on)
 * at least one SD card 
 * a Linux based system (a Mac should work but was not tested on)
 * patience (the whole build process can take quite a while)


**The process is a bit involved but pretty straighforward and reproducible once you get the hang of it. If you get stuck or have questions do reach out at hello@cattlepi.com**


## Step 1 - clone the latest CattlePi version
```bash
git clone git@github.com:cattlepi/cattlepi.git
cd cattlepi/
```

## Step 2 - ensure that you have python installed
```bash
python --version
```
Install for your own OS version/flavor if you don't have python installed.  

## Step 3 - ensure you have virtualenv installed
```bash
virtualenv --version
```
Install for your own OS version/flavor if you don't have virtualenv installed.  

## Step 4 - build the virtual environment you're going to use
From within the cattlepi dir run:
```bash
bin/build.sh tools_setup
```

## Step 5 - download the latest RASPBIAN STRETCH LITE
You can find it here: [https://downloads.raspberrypi.org/raspbian_lite_latest](https://downloads.raspberrypi.org/raspbian_lite_latest)

## Step 6 - write the latest raspian to the SD card  
You can use something like [Etcher](https://etcher.io/) for a painless, quick operation

## Step 7 - enable ssh
On the /boot partition for the sdcard, create an empty file named ssh. Also [see here](https://www.raspberrypi.org/documentation/remote-access/ssh/), method 3

## Step 8 - Boot up the Raspberry Pi
Insert the SD card into the Raspberry Pi
The Pi needs to have a physical ethernet connection. 
It also needs to be on the same network as your development machine.
Boot the Pi and learn its IP Address (this can be by looking at your router, using nmap, or connecting it to an external display - whichever works for you).
Let's assume the the IP of the PI is 192.168.1.12

## Step 9 - Copy your SSH key to the PI
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

## Step 10 - update the hosts file with your configurations
In the cattlepi directory, the **builder/hosts** file
Swap out your PI IP in the builder nodes configuration.
replace the api endpoint with http://192.168.1.166:4567 where 192.168.1.166 is the IP of your development machine.

In the cattlepi directory, the **server/bin/run_server.sh** file
Put your development machine ip in the SERVERIP export (same as above, e.g. 192.168.1.166)

## Step 11 - build the images
In the cattlepi directory, run
```bash
bin/build.sh
```
This will take anywhere between 15-40 minutes (depends on the speed of your internet connection for package downloads - as an example: when this was written and tested it took: 0:13:15.352). You can follow along in builder/stages.yaml to see all the operations that are invoked as part of the ansible playbook that builds the images.  
The build process will output 2 images in **builder/output**: initramfs.tgz is the **initfs** and rootfs.sqsh is the **rootfs**.  
You can and are actually encouraged to open up the files and look around. 

## Step 12 - copy the initfs on [another] SD card
Usually it's recommanded to have a 2nd SD card and 2nd RPi to not have to go through all the setup steps for the builder Pi every time you want to build the image (the builder used /tmp on the builder Pi, so reusing the builder should be doable). That being said, you can use the same SD card / same Pi if you want (or you can use 1 Pi w/ 2 cards - just be sure to properly shutdown the PIs)

Create a FAT partition and uncompress the contents of builder/output/initramfs.tgz onto the partition. You can do this manually or you can try using the following
```bash
bin/build.sh tools_copy_initfs_to_sdcard
```
Do keep in mind that using the script makes the assumption that the FAT partition is at /dev/mmcblk0p1 and that you don't have anything at /mnt/SD (so it may not work for you and you'll need to do this manually)

## Step 13 - start the local server which will be used to server the images
```bash
bin/build.sh tools_run_local_api
```

## Step 14 - insert the SD card into the RPi and boot it up
The Pi should boot and you should see it downloading the image files and the configuration, applying it and switching to the root filestystem that it has built.
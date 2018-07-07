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

## Step 4 - build the virtual environment you're going to use
From within the cattlepi directory run:
```bash
bin/build.sh tools_setup
```
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

Power up the Pi, let it boot, and note its IP Address (this can be done by looking at your router, using nmap, or connecting it to an external display - [see the FAQ for suggestions](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md#how-do-i-get-my-rpi's-ip-address?)).

Let's assume the the IP of the PI is 192.168.1.12

## Step 9 - Copy your SSH key to the PI
```bash
ssh pi@192.168.1.12 "mkdir -p ~/.ssh/"
cat ~/.ssh/id_rsa.pub | (ssh pi@192.168.1.12 "cat >> ~/.ssh/authorized_keys")
```
Make sure you swap out the IP with your own. Also, make sure that you have a valid public key for your development machine. If not, [you will need to generate one](https://github.com/cattlepi/cattlepi/blob/master/doc/FAQ.md#how-do-i-set-up-passwordless-ssh-on-the-raspberry-pi?).

The default password for the pi user on Raspian is **raspberry** (**NOTE:** it is good security policy to change this immediately, using the passwd command).  

Test that the passwordless interaction with your builder Pi now works
```bash
ssh pi@192.168.1.12 whoami
```
The previous command should no longer prompt you for a password

## Step 10 - update the hosts file with your configurations

In the cattlepi directory, edit the **builder/hosts** file by swapping out your Pi's IP in the builder nodes configuration:

```bash
[buildernodes]
192.168.1.12
```

Replace the API endpoint with http://192.168.1.166:4567 where 192.168.1.166 is the IP of your development machine.

In the cattlepi directory, edit the **server/bin/run_server.sh** file by putting your development machine's IP address in the SERVERIP export (same as above, e.g. 192.168.1.166):

```bash
export SERVERIP=192.168.1.166 # the ip which the server will listen to (change to the IP address of your development machine)
```

## Step 11 - build the images

In the cattlepi directory, run:
```bash
bin/build.sh
```
This will take anywhere between 15 - 40 minutes (depending on your internet connection for package downloads - as an example: when this was written and tested it took a little over 13 minutes). You can follow along in **builder/stages.yaml** to see all the operations that are invoked as part of the ansible playbook that builds the images.  
The build process will output two images in **builder/output**: initramfs.tgz is the **initfs** and rootfs.sqsh is the **rootfs**.  
You can — and are actively encouraged to — explore these files. 

## Step 12 - copy the initfs onto [another] SD card
I recommend having a second SD card and RPi, in order to avoid the tedium of the setup process each time you want to build the image. The builder used **/tmp** on the builder Pi; you can re-use the builder if you have the same hardware. Alternatively, you can use the same SD card/RPi, or even one RPi with two SD cards (just be sure to properly shut down the RPis between swapping out the SD cards).

Create a FAT partition and uncompress the contents of builder/output/initramfs.tgz onto the partition. You can do this manually, or you can try:
```bash
bin/build.sh tools_copy_initfs_to_sdcard
```
Keep in mind that the script assumes that the FAT partition is at **/dev/mmcblk0p1** and that you don't have anything at **/mnt/SD**. Consequently, you may require an alternative, manual, work-around. 

## Step 13 - start the local server (used to serve the images)
```bash
bin/build.sh tools_run_local_api
```

## Step 14 - insert the SD card into the RPi and boot it up
The Pi should boot and you should see it downloading the image files and the configuration, applying it and switching to the root filestystem that it has built.

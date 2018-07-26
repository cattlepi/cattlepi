# Frequently asked questions

## What types of hardware does this work on?
The default images you'll get have been tested on:
 * Raspberry Pi 3 Model B+
 * Raspberry Pi 3 Model B
 * Raspberry Pi 2 Model B

In theory it should work on any model compatible with the latest Raspian. Also in theory, you could build a rootfs image that only works on a certain type of hardware.

## How is this better than doing a network boot?
It's not. It's different.   

For a network boot you need to control the DHCP and TFTP server on your network. You also need something like NFS to mount the root file system. You also need to pre-program your Pi to be able to network boot (and only Model 3B/3B+ have the capability of network booting). On top of this, network booting may not be very reliable in the context of a normal network; the bootloader doesn't retry if it fails the first time and TFTP has been known to be unreliable for network transfer).

For CattlePi, you can simply plug the Pi into a network that will give it an IP address and provide internet connectivity (it's really connectivity to the API that's driving it) and you're set. You only need this connectivity during the boot process. Usually your Wi-Fi router will be the right place. You can plug it in and "forget about it".

## How is this better than PiNet (http://pinet.org.uk/) or PiServer?
It's not. It's different.  

With CattlePi the idea is to make the network set-up as simple as possible. It also aims to make the set-up and maintenance as touch-free as possible.  
For PiNet/PiServer I believe the goals are somewhat different (empowering learning and exposing people to using a Pi) and the set-up definitely needs to be maintained/thought about over time.

## Why is it called CattlePi?
> "It takes a family of three to care for a single puppy, but a few cowboys can drive tens of thousands of cows over great distances, all while drinking whiskey"  
> -- [Joshua McKenty](https://www.networkworld.com/article/2165267/cloud-computing/why-servers-should-be-seen-like-cows--not-puppies.html) 

You can read about the [history of the cattle vs. pets analogy here](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/).
We want to turn your pet project into a cattle project. 

## How do I get my RPi's IP address?

This can be done a number of ways.

 i. If you connect your RPi to an external display and keyboard, log in and enter:

```bash
sudo ifconfig
```
Because we are looking for the physical (ethernet) port, scan through the output for _eth0_. You should see something like:

```bash
eth0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether b8:27:eb:d9:58:71  txqueuelen 1000  (Ethernet)
        inet 192.168.1.12 netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 ::b9db:3d5b:e60e:decc  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::bf79:ce8f:a532:93ee  prefixlen 64  scopeid 0x20<link>
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

 ii. Check the assigned IP from the DNS table on your router's control panel. 
 This often involves navigating to the gateway IP for your router 
 (e.g. mine is http://192.168.0.1/), logging in, and checking the DNS tables. For example:

| Name | IP | MAC |
| raspberrypi | 192.168.1.12 | B8:27:EB:8C:0D:24 |

If you don't know your router's password, it may be set to the manufacturer's default. You may
find your model [listed here](http://www.routerpasswords.com/), however, only use this if you 
are legally entitled to do so.

## How do I set up passwordless ssh on the Raspberry Pi?

We couldn't have put it better than [this fine article on raspberrypi.org](
https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md)

---

## What do I do if my question is not in here?
Make a Pull Request to alter this file to add your question. We'll do our best to answer it.

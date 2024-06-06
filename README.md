# STMicroelectronics feed for OpenWRT

This repository is an OpenWRT feed dedicated to supporting the
[STMicroelectronics](https://www.st.com)
[STM32MP1](https://www.st.com/en/microcontrollers-microprocessors/stm32mp1-series.html)
platforms.

## Supported devices

1. `STM32MP157F-DK2`: minimal support for the STM32MP157F-DK2

2. `STM32MP135F-DK`: minimal support for the STM32MP135F-DK

3. `STM32MP157F-DK2-DEMO`: based on the `STM32MP157F-DK2` device including
   additional packages like a web interface to configure the device.

4. `STM32MP135F-DK-DEMO`: based on the `STM32MP135F-DK` device including
   additional packages like a web interface to configure the device.

|Supported features|STM32MP157F-DK2|STM32MP135F-DK|
|------------------|---------------|--------------|
|Sysupgrade|yes|yes|
|Ethernet|yes|yes|
|Watchdog|yes|yes|
|RTC|yes|yes|
|RNG (Optee)|yes|yes|
|LED|yes|yes|
|Button|no|yes (USER2)|
|Wifi|yes|yes|
|USB Type-A|yes|yes|

## BSP

This feed is based on the `STPM32MP1 BSP v5.0`.

|Components|Version|
|----------|-------|
|TF-A|v2.8-stm32mp-r1|
|U-Boot|v2022.10-stm32mp-r1|
|OPTEE|3.19.0-stm32mp-r1|
|Linux|OpenWRT kernel + v6.1-stm32mp-r1|

For the kernel, the patches from the v6.1-stm32mp branch until the tag
v6.1-stm32mp-r1 were added.  
They are available in `target/linux/stm32/patches-6.1/`.  

## Getting started

### Pre-requisites

In order to use [OpenWRT](https://openwrt.org/), you need to have a Linux or
Unix like distribution installed on your workstation.
And you need to install a set of packages as described in the
[OpenWRT Build system setup](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem).

### Getting the code

The feed is designed to work with the `master` branch of OpenWRT (last tested
commit is [cffd3ad8d7](https://github.com/openwrt/openwrt/commit/cffd3ad8d7)).

```bash
$ git clone -b master https://git.openwrt.org/openwrt/openwrt.git
$ cd openwrt
$ git checkout cffd3ad8d7
```

Next step is to add the [STMicroelectronics](https://www.st.com) feed in the
`feeds.conf.default` file.

```bash
$ cat feeds.conf.default
src-git st https://github.com/bootlin/openwrt-feed-st.git
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/project/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
#src-git video https://github.com/openwrt/video.git
#src-git targets https://github.com/openwrt/targets.git
#src-git oldpackages http://git.openwrt.org/packages.git
#src-link custom /usr/src/openwrt/custom-feed
```

Then fetch the code of all feeds

```bash
$ ./scripts/feeds update -a
```

### Install the feeds

Install stm32 target

```bash
$ ./scripts/feeds install stm32
```

Install all other packages

```bash
$ ./scripts/feeds install -a -f
```
(Some overriding warnings can occur, if you used `-f` please ignore them).

### Configure and build

Run `make menuconfig`

```bash
$ make menuconfig
```

Then select `STMicroelectronics STM32` for the `Target System`, `STM32MP1
boards` for the `Subtarget`, and select the `Target Profile` corresponding to
your hardware (for example `STMicroelectronics STM32MP135F-DK`).

Then to start the build.

```bash
$ make -j$(nproc)
```

## Flashing and booting the system

All images generated for the subtarget `stm32mp1` are stored in
`bin/targets/stm32/stm32mp1/`.
The images to flash on the SDCard are
`openwrt-stm32-stm32mp1-stm32mpXXXXX-ext4-factory.img.gz`.

```bash
$ gzip -d -c bin/targets/stm32/stm32mp1/openwrt-stm32-stm32mp1-stm32mp135f-dk-ext4-factory.img.gz | dd of=/dev/sdX
```
(Note: this assumes your SD card appears as `/dev/sdX` on your system.)

Then:

1. Insert the microSD card
   - STM32MP157: connector CN15
   - STM32MP135: connector CN3

2. Plug a micro-USB cable and run your serial communication program on
   /dev/ttyACM0.
   - STM32MP157: connector CN11
   - STM32MP135: connector CN10

3. Configure the SW1 switch to boot on SD card
   - STM32MP157: BOOT0 and BOOT2 to ON
   - STM32MP135: BOOT0 to ON, BOOT1 to OFF, BOOT2 to ON

4. Plug a USB-C cable to power-up the board
   - STM32MP157: connector CN6
   - STM32MP135: connector CN12

5. The system will start, with the console on UART. The default user is root
   with no password. The login is automatic.

```
BusyBox v1.36.1 (2024-02-14 15:44:53 UTC) built-in shell (ash)

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 OpenWrt SNAPSHOT, r24943+13-3a073a0212
 -----------------------------------------------------
=== WARNING! =====================================
There is no root password defined on this device!
Use the "passwd" command to set up a new password
in order to prevent unauthorized SSH logins.
--------------------------------------------------
root@OpenWrt:/#
```

## Additional informations

This chapter contains some informations which are specific to the stm32 target.
For the generic informations, please refer to the [Official OpenWRT
documentation](https://openwrt.org/docs/guide-user/start).

### Ethernet

The configuration of Ethernet interfaces is the default OpenWRT configuration:

- `STM32MP157F-DK2`: `lan` interface
- `STM32MP135F-DK`: `lan` interface (`ETH1`) and `wan` interface (`ETH2`)

The `lan` interface is configured with a static ip address 192.168.1.1 and a
dhcp server is running.  
The `wan` interface is in dhcp mode.  
By default the management protocols are only accessible from the lan interface.

### System upgrade

For a system upgrade, an upgrade image shall be used (image labelled
...-sysupgrade.img.gz).

The demo and non-demo profiles are compatible, it means you can update a
`STM32MP135F-DK` profile with a `STM32MP135F-DK-DEMO` image (vice versa) for
example.

By default, the sysupgrade mechanism updates the partitions one by one. If the
partition table is different (for example the rootfs partition is 10MiB bigger),
the full image is written.

The U-Boot environment variables are always preserved during an upgrade.  
To erase the environment variables, flash the factory image on the SDCard or
use the `env erase` command from U-Boot.

Useful link: [Upgrading OpenWrt firmware using LuCI and CLI](https://openwrt.org/docs/guide-user/installation/generic.sysupgrade)

### Button

The kernel module `gpio-button-hotplug` is used to support buttons.  
The `STM32MP135F-DK` has one supported button: `USR2` (key `BTN_1`).

To easily test the button:

```
mkdir -p /etc/hotplug.d/button

cat << "EOF" > /etc/hotplug.d/button/buttons
logger "the button was ${BUTTON} and the action was ${ACTION}"
EOF

root@OpenWrt:/# logread -f
Fri Mar 15 14:28:09 2024 user.notice root: the button was BTN_1 and the action was pressed
Fri Mar 15 14:28:09 2024 user.notice root: the button was BTN_1 and the action was released
```
Useful link: [Attach functions to a push button](https://openwrt.org/docs/guide-user/hardware/hardware.button)

### LED

One LED is defined and labelled `blue:heartbeat` (`LD8` for `STM32MP157F-DK2` and
`LD3` for `STM32MP135F-DK`). By default it is configured to use the heartbeat
trigger.

Useful link: [LED Configuration](https://openwrt.org/docs/guide-user/base-system/led_configuration)

### USB

Only mass storage are supported on the USB Type-A by default.

## Going further

* [Using the STM32 Cube Programmer](docs/stm32cubeprogrammer.md)
* [Benchmarking](docs/benchmarking.md)

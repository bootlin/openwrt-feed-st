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
|Ethernet|yes|yes|
|Watchdog|yes|yes|
|RTC|yes|yes|
|RNG (Optee)|yes|yes|
|LED|yes|yes|
|Button|no|yes (USER2)|
|Wifi|yes|yes|

## Getting started

### Pre-requisites

In order to use [OpenWRT](https://openwrt.org/), you need to have a Linux or
Unix like distribution installed on your workstation.
And you need to install a set of packages as described in the
[OpenWRT Build system setup](https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem).

### Getting the code

The feed is designed to work with the `master` branch of OpenWRT (last tested
commit is [904aa43865](https://github.com/openwrt/openwrt/commit/904aa43865)).

```bash
$ git clone -b master https://git.openwrt.org/openwrt/openwrt.git
$ cd openwrt
$ git checkout 904aa43865
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

### Install ptgen patch

We need to apply a patch on the host tool `firmware-utils` to be able to build
bootable images.

```bash
$ mkdir tools/firmware-utils/patches/
$ cp feeds/st/patches/0001-ptgen-fix-limitation-for-active-partition-in-GPT.patch \
     tools/firmware-utils/patches/
```
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

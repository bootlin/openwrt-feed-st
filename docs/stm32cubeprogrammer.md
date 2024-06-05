# Using STM32 Cube Programmer

[STM32 Cube
Programmer](https://www.st.com/en/development-tools/stm32cubeprog.html)
is a utility provided by ST that allows to reflash an STM32MP1
platform directly from your PC.

To get started, download STM32 Cube Programmer from the [ST
website](https://www.st.com/en/development-tools/stm32cubeprog.html).
We tested with version 2.16.0, and the below instructions assume that STM32 Cube
Programmer is installed in the `$HOME/stm32cube` folder.

STM32 Cube Programmer will be used to reflash the SD card, with the SD
card inserted in the STM32MP1 platform.

The following procedure (done for the stm32mp157f-dk2 profile) is also valid for
stm32mp135f-dk and the demo profiles.

Follow these steps:

1. Switch the boot mode switch SW1 to USB boot
2. Plug a second USB-C cable on CN7
3. Copy images in a dedicated folder
```bash
$ mkdir flash
$ cp bin/targets/stm32/stm32mp1/trusted-firmware-a-stm32mp157f-dk2/tf-a-stm32mp157f-dk2.stm32 flash/
$ cp staging_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/image/fip-stm32mp157f-dk2.bin flash/
$ cp bin/targets/stm32/stm32mp1/openwrt-stm32-stm32mp1-stm32mp157f-dk2-ext4-factory.img.gz flash/
```
4. Decompress the factory image
```bash
$ gzip -d flash/openwrt-stm32-stm32mp1-stm32mp157f-dk2-ext4-factory.img.gz
```
5. Create the `flash.tsv` file
```bash
$ cat flash/flash.tsv
-	0x01	fsbl-boot	Binary	none	0x0	tf-a-stm32mp157f-dk2.stm32
-	0x03	fip-boot	FIP	none	0x0	fip-stm32mp157f-dk2.bin
P	0x10	sdcard		RawImage	mmc0	0x0	openwrt-stm32-stm32mp1-stm32mp157f-dk2-ext4-factory.img
```
6. Run the command to start flashing
```
$ $HOME/stm32cube/bin/STM32_Programmer_CLI -c port=usb1 -w ./flash/flash.tsv
```
7. Switch back the boot mode switch to SD boot
8. Reboot the platform

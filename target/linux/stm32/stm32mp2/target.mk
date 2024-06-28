# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Bootlin
#

BOARDNAME:=STM32MP2 boards
ARCH:=aarch64
CPU_TYPE:=cortex-a35
CPU_SUBTYPE=fp-armv8
FEATURES+=fpu
KERNEL_IMAGES:=Image.gz

DEFAULT_PACKAGES += blockdev kmod-gpio-button-hotplug

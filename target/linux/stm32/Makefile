# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Bootlin
#

include $(TOPDIR)/rules.mk

BOARD:=stm32
BOARDNAME:=STMicroelectronics STM32
FEATURES:=boot-part emmc ext4 gpio rtc usb display audio
SUBTARGETS:=stm32mp1 stm32mp2
CPU_TYPE:=

KERNEL_PATCHVER:=6.6

include $(INCLUDE_DIR)/target.mk

define Target/Description
	Build firmware image for STM32 devices
endef

$(eval $(call BuildTarget))

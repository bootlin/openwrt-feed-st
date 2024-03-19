# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Bootlin
#

LUCI := uhttpd luci luci-ssl luci-theme-openwrt-2020 \
	luci-app-ledtrig-usbport

define Device/Demo
  DEVICE_VARIANT := (demo)
  DEVICE_PACKAGES += $(LUCI)
endef

define Device/stm32mp157f-dk2-demo
  $(call Device/stm32mp157f-dk2)
  $(call Device/Demo)
  DEVICE_NAME := stm32mp157f-dk2
endef

define Device/stm32mp135f-dk-demo
  $(call Device/stm32mp135f-dk)
  $(call Device/Demo)
  DEVICE_NAME := stm32mp135f-dk
endef

ifeq ($(SUBTARGET),stm32mp1)
  TARGET_DEVICES += \
		    stm32mp157f-dk2-demo \
		    stm32mp135f-dk-demo
endif

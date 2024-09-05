#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define KernelPackage/usb-stm32-usbh
  TITLE:=STM32 USB2 Host Glue support
  KCONFIG = CONFIG_USB_STM32_USBH
  FILES:= \
	$(LINUX_DIR)/drivers/usb/host/usbh-stm32.ko
  AUTOLOAD:=$(call AutoLoad,45,usbh_stm32,1)
  $(call AddDepends/usb,@TARGET_stm32_stm32mp2)
endef

define KernelPackage/usb-stm32-usbh/description
  Enables support for USB2 Host controller on STM32MP25, configures
  glue logic around EHCI and OHCI host controller handled via
  ehci-platform.o and ohci-platform.o.
endef

$(eval $(call KernelPackage,usb-stm32-usbh))

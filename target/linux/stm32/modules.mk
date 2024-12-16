#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define KernelPackage/phy-stm32-usbphyc
  TITLE:=STM32 USB HS PHY Controller driver
  DEPENDS:=@TARGET_stm32
  KCONFIG:=CONFIG_PHY_STM32_USBPHYC
  FILES:=$(LINUX_DIR)/drivers/phy/st/phy-stm32-usbphyc.ko
  AUTOLOAD:=$(call AutoProbe,phy-stm32-usbphyc,)
endef

define KernelPackage/phy-stm32-usbphyc/description
  Kernel module for STM32 USB HS PHY Controller
endef

$(eval $(call KernelPackage,phy-stm32-usbphyc))


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

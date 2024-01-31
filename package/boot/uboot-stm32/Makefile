#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=2022.10-stm32mp-r1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/STMicroelectronics/u-boot.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=f6a8fac9a10338f345a834ed0381eb771d145e0fd876d583e723392b0de91b25
PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>

UBOOT_USE_INTREE_DTC:=1

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET=stm32
  UBOOT_IMAGE:=u-boot-nodtb.bin
endef

define U-Boot/stm32mp15
  BUILD_SUBTARGET:=stm32mp1
  UBOOT_CONFIG:=stm32mp15
endef

define U-Boot/stm32mp13
  BUILD_SUBTARGET:=stm32mp1
  UBOOT_CONFIG:=stm32mp13
endef

define U-Boot/stm32mp157f-dk2
  $(call U-Boot/stm32mp15)
  NAME:=STM32MP157F-DK2
  DEVICE_TREE:=stm32mp157f-dk2
endef

define U-Boot/stm32mp135f-dk
  $(call U-Boot/stm32mp13)
  NAME:=STM32MP135F-DK
  DEVICE_TREE:=stm32mp135f-dk
endef

UBOOT_TARGETS := \
	stm32mp157f-dk2 \
	stm32mp135f-dk

UBOOT_MAKE_FLAGS += DEVICE_TREE=$(DEVICE_TREE)

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(UBOOT_IMAGE) \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/u-boot.dtb \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.dtb
endef

define Package/u-boot/install/default
endef


$(eval $(call BuildPackage/U-Boot))

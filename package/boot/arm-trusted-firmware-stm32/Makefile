#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=2.10-stm32mp-r1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/STMicroelectronics/arm-trusted-firmware.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=7af0d84c464f7a51e4ef727962b50c1a8d42e70518ae3330b1b5d6b3399b0c3f

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/trusted-firmware-a.mk
include $(INCLUDE_DIR)/package.mk

define Trusted-Firmware-A/Default
  BUILD_TARGET:=stm32
  BUILD_DEVICES:=$(1) $(1)-demo
  DEPENDS:=+u-boot-$(1) +optee-os-$(1)
endef

define Trusted-Firmware-A/stm32mp1
  BUILD_SUBTARGET:=stm32mp1
  PLAT:=stm32mp1
  MAKE_ARGS += BL32_EXTRA2=$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-pageable_v2.bin \
	       STM32MP_USB_PROGRAMMER=1 \
	       STM32MP1_OPTEE_IN_SYSRAM=1 \
	       ARM_ARCH_MAJOR=7
endef

define Trusted-Firmware-A/stm32mp2
  BUILD_SUBTARGET:=stm32mp2
  PLAT:=stm32mp2
  METADATA:=1
  MAKE_ARGS = STM32MP_DDR4_TYPE=1 \
	      ARM_ARCH_MAJOR=8
endef

define Trusted-Firmware-A/stm32mp157f-dk2
  $(call Trusted-Firmware-A/stm32mp1)
  NAME:=STM32MP157F-DK2
  DTB_FILE_NAME:=stm32mp157f-dk2.dtb
endef

define Trusted-Firmware-A/stm32mp135f-dk
  $(call Trusted-Firmware-A/stm32mp1)
  NAME:=STM32MP135F-DK
  DTB_FILE_NAME=stm32mp135f-dk.dtb
endef

define Trusted-Firmware-A/stm32mp257f-ev1
  $(call Trusted-Firmware-A/stm32mp2)
  NAME:=STM32MP257F-EV1
  DTB_FILE_NAME:=stm32mp257f-ev1.dtb
endef

TFA_TARGETS := \
	       stm32mp157f-dk2 \
	       stm32mp135f-dk \
	       stm32mp257f-ev1

TFA_MAKE_FLAGS += \
		$(if $(CONFIG_BINUTILS_VERSION_2_37)$(CONFIG_BINUTILS_VERSION_2_38),,LDFLAGS="-no-warn-rwx-segments") \
		$(if $(CONFIG_aarch64), ARCH=aarch64 SPD=opteed, ARCH=aarch32 AARCH32_SP=optee) \
		BL32=$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-header_v2.bin \
		BL32_EXTRA1=$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-pager_v2.bin \
		BL33=$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.bin \
		BL33_CFG=$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.dtb \
		DTB$(if $(findstring stm32mp2, $(CONFIG_TARGET_SUBTARGET)),_FIDTB)_FILE_NAME=$(DTB_FILE_NAME) \
		STM32MP_SDMMC=1 \
		TARGET_BOARD="" \
		$(MAKE_ARGS) \
		all fip

define Package/trusted-firmware-a/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(CP) $(PKG_BUILD_DIR)/build/$(PLAT)/release/tf-a-$(BUILD_VARIANT).stm32 \
		$(STAGING_DIR_IMAGE)/tf-a-$(BUILD_VARIANT).stm32
	$(CP) $(PKG_BUILD_DIR)/build/$(PLAT)/release/fip.bin \
		$(STAGING_DIR_IMAGE)/fip-$(BUILD_VARIANT).bin
endef

$(eval $(call BuildPackage/Trusted-Firmware-A))

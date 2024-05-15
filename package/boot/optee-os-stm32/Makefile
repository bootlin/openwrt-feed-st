#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=3.19.0-stm32mp-r1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/STMicroelectronics/optee_os.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=36a4843391a452075d6a690ad253ad887aa523c2705e1d438cf41e8821ee9439
PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>

OPTEE_USE_INTREE_DTC:=1

include optee-os.mk
include $(INCLUDE_DIR)/package.mk

define Optee-os/Default
  BUILD_TARGET:=stm32
  OPTEE_IMAGE:=tee-header_v2.bin tee-pager_v2.bin tee-pageable_v2.bin
endef

define Optee-os/stm32mp1
  BUILD_SUBTARGET:=stm32mp1
  PLAT:=stm32mp1
  OPTEE_MAKE_FLAGS += CFG_ARM32_core=y
endef

define Optee-os/stm32mp157f-dk2
  $(call Optee-os/stm32mp1)
  NAME:=STM32MP157F-DK2
  PLAT_FLAVOR:=157F_DK2
  OPTEE_MAKE_FLAGS += CFG_STM32MP1_OPTEE_IN_SYSRAM=y
endef

define Optee-os/stm32mp135f-dk
  $(call Optee-os/stm32mp1)
  NAME:=STM32MP135F-DK
  PLAT_FLAVOR:=135F_DK
endef

OPTEE_TARGETS := \
	stm32mp157f-dk2 \
	stm32mp135f-dk

define Package/optee-os/install/default
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-$(PLAT)/core/tee-header_v2.bin \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-header_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-$(PLAT)/core/tee-pager_v2.bin \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-pager_v2.bin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/out/arm-plat-$(PLAT)/core/tee-pageable_v2.bin \
		$(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-tee-pageable_v2.bin
endef

$(eval $(call BuildPackage/Optee-os))

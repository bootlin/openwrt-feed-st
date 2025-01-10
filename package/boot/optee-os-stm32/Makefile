#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=4.0.0-stm32mp-r1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/STMicroelectronics/optee_os.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=a61a8dcf2e374ce7ce40875ccf634cbdfdd4881e381b7afa2e1a05a991bea5c4
PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>

OPTEE_USE_INTREE_DTC:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/optee-os.mk
include $(INCLUDE_DIR)/package.mk

define Optee-os/Default
  BUILD_TARGET:=stm32
endef

define Optee-os/stm32mp1
  BUILD_SUBTARGET:=stm32mp1
  PLAT:=stm32mp1
endef

define Optee-os/stm32mp2
  BUILD_SUBTARGET:=stm32mp2
  PLAT:=stm32mp2
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

define Optee-os/stm32mp257f-ev1
  $(call Optee-os/stm32mp2)
  NAME:=STM32MP257F-EV1
  OPTEE_MAKE_FLAGS += CFG_EMBED_DTB_SOURCE_FILE=stm32mp257f-ev1.dts \
		      CFG_SCMI_SCPFW=y
endef

OPTEE_TARGETS := \
	stm32mp157f-dk2 \
	stm32mp135f-dk \
	stm32mp257f-ev1

define Package/optee-os/install/default
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(foreach img,$(OPTEE_IMAGE), \
		$(CP) $(PKG_BUILD_DIR)/out/arm-plat-$(PLAT)/core/$(img) $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-$(img); \
	)
endef

$(eval $(call BuildPackage/Optee-os))

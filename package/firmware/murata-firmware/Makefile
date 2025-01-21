#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=murata-firmware
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-07-03
PKG_SOURCE_URL:=https://github.com/murata-wireless/cyw-fmac-fw.git
PKG_MIRROR_HASH:=1cb50cb02eb74f2fd4005912a9e25ac28b76ea0fea04fd5448656f14ec1f2233
PKG_SOURCE_VERSION:=a80cb77798a8d57f15b7c3fd2be65553d9bd5125

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/murata-firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://community.murata.com/
endef

define Build/Compile
endef

define Package/murata-firmware-43430-sdio
  $(Package/murata-firmware-default)
  TITLE:=BCM43430 FullMac SDIO firmware
  CONFLICTS:=cypress-firmware-43430-sdio
endef

define Package/murata-firmware-43439-sdio
  $(Package/murata-firmware-default)
  TITLE:=BCM43439 FullMac SDIO firmware
  CONFLICTS:=cypress-firmware-43439-sdio
endef

define Package/murata-firmware-43430-sdio/install
	$(INSTALL_DIR) $(1)/lib/firmware/murata
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/cyfmac43430-sdio.bin \
		$(1)/lib/firmware/murata/
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/cyfmac43430-sdio.1DX.clm_blob \
		$(1)/lib/firmware/murata/
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(LN) \
		../murata/cyfmac43430-sdio.bin \
		$(1)/lib/firmware/brcm/brcmfmac43430-sdio.bin
	$(LN) \
		../murata/cyfmac43430-sdio.1DX.clm_blob \
		$(1)/lib/firmware/brcm/brcmfmac43430-sdio.clm_blob
endef

define Package/murata-firmware-43439-sdio/install
	$(INSTALL_DIR) $(1)/lib/firmware/murata
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/cyfmac43439-sdio.bin \
		$(1)/lib/firmware/murata/
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/cyfmac43439-sdio.1YN.clm_blob \
		$(1)/lib/firmware/murata/
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(LN) \
		../murata/cyfmac43439-sdio.bin \
		$(1)/lib/firmware/brcm/brcmfmac43439-sdio.bin
	$(LN) \
		../murata/cyfmac43439-sdio.1YN.clm_blob \
		$(1)/lib/firmware/brcm/brcmfmac43439-sdio.clm_blob
endef
$(eval $(call BuildPackage,murata-firmware-43430-sdio))
$(eval $(call BuildPackage,murata-firmware-43439-sdio))


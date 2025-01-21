#
# Copyright (C) 2024 Bootlin
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=murata-nvram
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-06-12
PKG_SOURCE_URL:=https://github.com/murata-wireless/cyw-fmac-nvram.git
PKG_MIRROR_HASH:=a3b66bfb9c9a6ea66fe9e1386eb79f34e9009e00b071a8d547c2054069e0e4a6
PKG_SOURCE_VERSION:=61b41349b5aa95227b4d2562e0d0a06ca97a6959

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>
PKG_LICENSE_FILES:=LICENCE.cypress

include $(INCLUDE_DIR)/package.mk

define Package/murata-nvram-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://community.murata.com/
endef

define Build/Compile
endef

define Package/murata-nvram-43430-sdio
  $(Package/murata-nvram-default)
  TITLE:=BCM43430 SDIO NVRAM
  CONFLICTS:=brcmfmac-nvram-43430-sdio
endef

define Package/murata-nvram-43439-sdio
  $(Package/murata-nvram-default)
  TITLE:=BCM43439 SDIO NVRAM
  CONFLICTS:=brcmfmac-nvram-43439-sdio
endef

define Package/murata-nvram-43430-sdio/install
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(INSTALL_DATA)	./files/cyfmac43430-sdio.1DX.stm32.txt \
		$(1)/lib/firmware/brcm/
	$(LN) \
		cyfmac43430-sdio.1DX.stm32.txt \
		$(1)/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp135f-dk.txt
	$(LN) \
		cyfmac43430-sdio.1DX.stm32.txt \
		$(1)/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp157f-dk2.txt

endef

define Package/murata-nvram-43439-sdio/install
	$(INSTALL_DIR) $(1)/lib/firmware/brcm
	$(INSTALL_DATA)	./files/cyfmac43439-sdio.1YN.stm32.txt \
		$(1)/lib/firmware/brcm/
	$(LN) \
		cyfmac43439-sdio.1YN.stm32.txt \
		$(1)/lib/firmware/brcm/brcmfmac43439-sdio.st,stm32mp257f-dk.txt
endef

$(eval $(call BuildPackage,murata-nvram-43430-sdio))
$(eval $(call BuildPackage,murata-nvram-43439-sdio))

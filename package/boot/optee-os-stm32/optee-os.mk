include $(INCLUDE_DIR)/prereq.mk

PKG_NAME ?= optee-os

PKG_BUILD_DIR = $(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_TARGETS := bin
PKG_FLAGS:=nonshared

PKG_LICENSE:=BSD 2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL ?= 1

$(eval $(call TestHostCommand,python3-cryptography, \
  Please install the Python3 cryptography module, \
  $(STAGING_DIR_HOST)/bin/python3 -c 'import cryptography'))

#ifdef OPTEE_USE_INTREE_DTC
  $(eval $(call TestHostCommand,python3-pyelftools, \
    Please install the Python3 pyelftools module, \
    $(STAGING_DIR_HOST)/bin/python3 -c 'import elftools'))

  $(eval $(call TestHostCommand,dtc, \
    Please install the device-tree-compiler package, \
    dtc -version))
#endif

export GCC_HONOUR_COPTS=s

$(eval $(call TestHostCommand,python3-pyelftools, \
  Please install the Python3 elftools module, \
$(STAGING_DIR_HOST)/bin/python3 -c 'import elftools'))

define Package/optee-os/install/default
	$(CP) $(patsubst %,$(PKG_BUILD_DIR)/out/arm-plat-$(PLAT)/core/%,$(OPTEE_IMAGE)) $(1)/
endef

Package/optee-os/install = $(Package/optee-os/install/default)

define Optee-os/Init
  BUILD_TARGET:=
  BUILD_SUBTARGET:=
  BUILD_DEVICES:=
  NAME:=
  DEPENDS:=
  HIDDEN:=
  DEFAULT:=
  VARIANT:=$(1)
  PLAT:=$(1)
  PLAT_FLAVOR:=
  OPTEE_IMAGE:=
endef

TARGET_DEP = TARGET_$(BUILD_TARGET)$(if $(BUILD_SUBTARGET),_$(BUILD_SUBTARGET))

OPTEE_MAKE_FLAGS = 

define Build/Optee-os/Target
  $(eval $(call Optee-os/Init,$(1)))
  $(eval $(call Optee-os/Default,$(1)))
  $(eval $(call Optee-os/$(1),$(1)))

  define Package/optee-os-$(1)
    SECTION:=boot
    CATEGORY:=Boot Loaders
    TITLE:=OPTEE-OS for $(NAME)
    VARIANT:=$(VARIANT)
    DEPENDS:=@!IN_SDK $(DEPENDS)
    HIDDEN:=$(HIDDEN)
    ifneq ($(BUILD_TARGET),)
      DEPENDS += @$(TARGET_DEP)
      ifneq ($(BUILD_DEVICES),)
        DEFAULT := y if ($(TARGET_DEP)_Default \
		$(patsubst %,|| $(TARGET_DEP)_DEVICE_%,$(BUILD_DEVICES)) \
		$(patsubst %,|| $(patsubst TARGET_%,TARGET_DEVICE_%,$(TARGET_DEP))_DEVICE_%,$(BUILD_DEVICES)))
      endif
    endif
    $(if $(DEFAULT),DEFAULT:=$(DEFAULT))
    URL:=https://optee.readthedocs.io
  endef

  define Package/optee-os-$(1)/install
	$$(Package/optee-os/install)
  endef
endef

define Build/Configure/Optee-os
endef

define Build/Compile/Optee-os
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		CROSS_COMPILE_core="$(TARGET_CROSS)" \
		CROSS_COMPILE_ta_arm64="$(TARGET_CROSS)" \
		CROSS_COMPILE_ta_arm32="$(TARGET_CROSS)" \
		CFG_ARM32_core=y \
		PLATFORM="$(PLAT)" \
		PLATFORM_FLAVOR="$(call qstrip,$(PLAT_FLAVOR))" \
		$(OPTEE_MAKE_FLAGS)
endef

define BuildPackage/Optee-os/Defaults
  Build/Configure/Default = $$$$(Build/Configure/Optee-os)
  Build/Compile/Default = $$$$(Build/Compile/Optee-os)
endef

define BuildPackage/Optee-os
  $(eval $(call BuildPackage/Optee-os/Defaults))
  $(foreach type,$(if $(DUMP),$(OPTEE_TARGETS),$(BUILD_VARIANT)), \
    $(eval $(call Build/Optee-os/Target,$(type)))
  )
  $(eval $(call Build/DefaultTargets))
  $(foreach type,$(if $(DUMP),$(OPTEE_TARGETS),$(BUILD_VARIANT)), \
    $(call BuildPackage,optee-os-$(type))
  )
endef

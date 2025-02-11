# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Bootlin

define KernelPackage/bxcan
  TITLE:=STM32 Basic Extended CAN (bxCAN) devices
  KCONFIG:=CONFIG_CAN_BXCAN
  FILES=$(LINUX_DIR)/drivers/net/can/bxcan.ko
  AUTOLOAD:=$(call AutoProbe,bxcan)
  $(call AddDepends/can,@TARGET_stm32)
endef

$(eval $(call KernelPackage,bxcan))


define KernelPackage/drm-dw-mipi-dsi
  SUBMENU:=$(VIDEO_MENU)
  TITLE:=Synopsis Designware MIPI DSI
  DEPENDS:=@DISPLAY_SUPPORT +kmod-drm +kmod-drm-kms-helper
  KCONFIG:=CONFIG_DRM_DW_MIPI_DSI
  FILES:=$(LINUX_DIR)/drivers/gpu/drm/bridge/synopsys/dw-mipi-dsi.ko
  AUTOLOAD:=$(call AutoProbe,dw-mipi-dsi)
endef

$(eval $(call KernelPackage,drm-dw-mipi-dsi))


define KernelPackage/drm-panel-rocktech-hx8394
  SUBMENU:=$(VIDEO_MENU)
  TITLE:=Rocktech HX8394 720x1280 DSI video mode panel
  DEPENDS:=@DISPLAY_SUPPORT +kmod-drm +kmod-backlight kmod-drm-stm
  KCONFIG:=CONFIG_DRM_PANEL_ROCKTECH_HX8394
  FILES=$(LINUX_DIR)/drivers/gpu/drm/panel/panel-rocktech-hx8394.ko
  AUTOLOAD:=$(call AutoProbe,panel-rocktech-hx8394)
endef

$(eval $(call KernelPackage,drm-panel-rocktech-hx8394))


define KernelPackage/drm-stm
  SUBMENU:=$(VIDEO_MENU)
  TITLE:=DRM Support for STMicroelectronics SoC Series
  DEPENDS:=@DISPLAY_SUPPORT +kmod-drm +kmod-drm-kms-helper +kmod-drm-dma-helper +kmod-drm-dw-mipi-dsi
  KCONFIG:=CONFIG_DRM_STM \
	   CONFIG_DRM_STM_DSI \
	   CONFIG_DRM_STM_LVDS
  FILES=$(LINUX_DIR)/drivers/gpu/drm/stm/stm-drm.ko \
	$(LINUX_DIR)/drivers/gpu/drm/stm/dw_mipi_dsi-stm.ko \
	$(LINUX_DIR)/drivers/gpu/drm/stm/lvds.ko
  AUTOLOAD:=$(call AutoProbe,stm-drm dw_mipi_dsi-stm lvds)
endef

$(eval $(call KernelPackage,drm-stm))


define KernelPackage/industrialio-backend
  TITLE:=IIO Backend support
  KCONFIG=CONFIG_IIO_BACKEND
  FILES:=$(LINUX_DIR)/drivers/iio/industrialio-backend.ko
  AUTOLOAD:=$(call AutoProbe,industrialio-backend)
  $(call AddDepends/iio)
endef

$(eval $(call KernelPackage,industrialio-backend))


define KernelPackage/nvmem-stm32-romem
  SUBMENU:=$(OTHER_MENU)
  TITLE:=STM32 factory-programmed memory support
  DEPENDS:=@TARGET_stm32
  KCONFIG:=CONFIG_NVMEM_STM32_ROMEM
  FILES:=$(LINUX_DIR)/drivers/nvmem/nvmem_stm32_romem.ko
  AUTOLOAD:=$(call AutoProbe,nvmem-stm32-romem)
endef

$(eval $(call KernelPackage,nvmem-stm32-romem))


define KernelPackage/nvmem-stm32-tamp
  SUBMENU:=$(OTHER_MENU)
  TITLE:=STMicroelectronics STM32 TAMP backup registers support
  DEPENDS:=@TARGET_stm32
  KCONFIG:=CONFIG_NVMEM_STM32_TAMP
  FILES:=$(LINUX_DIR)/drivers/nvmem/nvmem_stm32_tamp_nvram.ko
  AUTOLOAD:=$(call AutoProbe,nvmem_stm32_tamp_nvram)
endef

$(eval $(call KernelPackage,nvmem-stm32-tamp))


define KernelPackage/phy-stm32-usbphyc
  TITLE:=STM32 USB HS PHY Controller driver
  DEPENDS:=@TARGET_stm32
  SUBMENU:=$(USB_MENU)
  KCONFIG:=CONFIG_PHY_STM32_USBPHYC
  FILES:=$(LINUX_DIR)/drivers/phy/st/phy-stm32-usbphyc.ko
  AUTOLOAD:=$(call AutoProbe,phy-stm32-usbphyc,)
endef

define KernelPackage/phy-stm32-usbphyc/description
  Kernel module for STM32 USB HS PHY Controller
endef

$(eval $(call KernelPackage,phy-stm32-usbphyc))


define KernelPackage/scmi-hwmon
  TITLE:=ARM SCMI Sensors
  KCONFIG:=CONFIG_SENSORS_ARM_SCMI
  FILES:=$(LINUX_DIR)/drivers/hwmon/scmi-hwmon.ko
  AUTOLOAD:=$(call AutoProbe,scmi-hwmon)
  $(call AddDepends/hwmon,@TARGET_stm32 +kmod-thermal)
endef

$(eval $(call KernelPackage,scmi-hwmon))


define KernelPackage/scmi-iio
  TITLE:=IIO SCMI
  KCONFIG=CONFIG_IIO_SCMI
  FILES:=$(LINUX_DIR)/drivers/iio/common/scmi_sensors/scmi_iio.ko
  AUTOLOAD:=$(call AutoProbe,scmi_iio)
  $(call AddDepends/iio,@TARGET_stm32 +kmod-iio-kfifo-buf)
endef

$(eval $(call KernelPackage,scmi-iio))


define KernelPackage/sound-soc-stm32-dfsdm
  TITLE:=SoC Audio support for STM32 DFSDM
  KCONFIG:=CONFIG_SND_SOC_STM32_DFSDM
  FILES:=$(LINUX_DIR)/sound/soc/stm/stm32_adfsdm.ko
  AUTOLOAD:=$(call AutoProbe,stm32_adfsdm)
  $(call AddDepends/sound,@TARGET_stm32 +kmod-sound-soc-core +kmod-stm32-dfsdm-adc +kmod-industrialio-buffer-cb)
endef

$(eval $(call KernelPackage,sound-soc-stm32-dfsdm))


define KernelPackage/sound-soc-stm32-i2s
  TITLE:=STM32 I2S interface (SPI/I2S block) support
  KCONFIG:=CONFIG_SND_SOC_STM32_I2S
  FILES:=$(LINUX_DIR)/sound/soc/stm/snd-soc-stm32-i2s.ko
  AUTOLOAD:=$(call AutoProbe,snd-soc-stm32-i2s)
  $(call AddDepends/sound,@TARGET_stm32 +kmod-sound-soc-core)
endef

$(eval $(call KernelPackage,sound-soc-stm32-i2s))


define KernelPackage/sound-soc-stm32-mdf
  TITLE:=SoC Audio support for STM32 MDF
  KCONFIG:=CONFIG_SND_SOC_STM32_MDF
  FILES:=$(LINUX_DIR)/sound/soc/stm/stm32_amdf.ko
  $(call AddDepends/sound,@TARGET_stm32_stm32mp2 +kmod-stm32-mdf-adc +kmod-sound-soc-dmic \
	  +kmod-industrialio-buffer-cb)
endef

$(eval $(call KernelPackage,sound-soc-stm32-mdf))


define KernelPackage/sound-soc-stm32-sai
  TITLE:=STM32 SAI interface (Serial Audio Interface) support
  KCONFIG:=CONFIG_SND_SOC_STM32_SAI
  FILES:=$(LINUX_DIR)/sound/soc/stm/snd-soc-stm32-sai-sub.ko \
	 $(LINUX_DIR)/sound/soc/stm/snd-soc-stm32-sai.ko
  AUTOLOAD:=$(call AutoProbe,snd-soc-stm32-sai-sub snd-soc-stm32-sai)
  $(call AddDepends/sound,@TARGET_stm32 +kmod-sound-soc-core)
endef

$(eval $(call KernelPackage,sound-soc-stm32-sai))


define KernelPackage/sound-soc-stm32-spdifrx
  TITLE:=STM32 S/PDIF receiver (SPDIFRX) support
  KCONFIG:=CONFIG_SND_SOC_STM32_SPDIFRX
  FILES:=$(LINUX_DIR)/sound/soc/stm/snd-soc-stm32-spdifrx.ko
  AUTOLOAD:=$(call AutoProbe,snd-soc-stm32-spdifrx)
  $(call AddDepends/sound,@TARGET_stm32 +kmod-sound-soc-core)
endef

$(eval $(call KernelPackage,sound-soc-stm32-spdifrx))


define KernelPackage/sound-soc-wm8994
  TITLE:=Wolfson Microelectronics WM8994 codec
  KCONFIG:=CONFIG_SND_SOC_WM8994
  FILES:=$(LINUX_DIR)/sound/soc/codecs/snd-soc-wm8994.ko
  AUTOLOAD:=$(call AutoProbe,snd-soc-wm8994)
  $(call AddDepends/sound,+kmod-sound-soc-core +kmod-sound-soc-wm-hubs +kmod-i2c-core \
	  +kmod-regmap-i2c)
endef

$(eval $(call KernelPackage,sound-soc-wm8994))


define KernelPackage/sound-soc-wm-hubs
  TITLE:=Wolfson Microelectronics HUBS support
  KCONFIG:=CONFIG_SND_SOC_WM_HUBS
  FILES:=$(LINUX_DIR)/sound/soc/codecs/snd-soc-wm-hubs.ko
  AUTOLOAD:=$(call AutoProbe,snd-soc-wm-hubs)
  $(call AddDepends/sound,+kmod-sound-soc-core)
endef

$(eval $(call KernelPackage,sound-soc-wm-hubs))


define KernelPackage/spi-stm32
  SUBMENU=$(SPI_MENU)
  TITLE:=STM32 SPI controller
  DEPENDS:=@TARGET_stm32
  KCONFIG:=CONFIG_SPI_STM32 \
	   CONFIG_SPI=y \
	   CONFIG_SPI_MASTER=y \
	   CONFIG_SPI_SLAVE_TIME=n \
	   CONFIG_SPI_SLAVE_SYSTEM_CONTROL=n
  FILES=$(LINUX_DIR)/drivers/spi/spi-stm32.ko
  AUTOLOAD:=$(call AutoProbe,spi-stm32)
endef

define KernelPackage/spi-stm32/description
  SPI driver for STMicroelectronics STM32 SoCs.
endef

$(eval $(call KernelPackage,spi-stm32))


define KernelPackage/stm32-adc
  TITLE:=STM32 ADC
  KCONFIG:=CONFIG_STM32_ADC_CORE \
	   CONFIG_STM32_ADC
  FILES:=$(LINUX_DIR)/drivers/iio/adc/stm32-adc-core.ko \
	 $(LINUX_DIR)/drivers/iio/adc/stm32-adc.ko
  AUTOLOAD:=$(call AutoProbe,stm32-adc-core stm32-adc)
  $(call AddDepends/iio,@TARGET_stm32 +kmod-stm32-timer-trigger +kmod-industrialio-triggered-buffer)
endef

$(eval $(call KernelPackage,stm32-adc))


define KernelPackage/stm32-crc32
  TITLE:=Support for STM32 crc accelerators
  KCONFIG:=CONFIG_CRYPTO_DEV_STM32_CRC \
	   CONFIG_CRYPTO_HW=y
  FILES:=$(LINUX_DIR)/drivers/crypto/stm32/stm32-crc32.ko
  AUTOLOAD:=$(call AutoProbe,stm32-crc32)
  $(call AddDepends/crypto,@TARGET_stm32 +kmod-crypto-crc32)
endef

$(eval $(call KernelPackage,stm32-crc32))


define KernelPackage/stm32-cryp
  TITLE:=Support for STM32 cryp accelerators
  KCONFIG:=CONFIG_CRYPTO_DEV_STM32_CRYP \
	   CONFIG_CRYPTO_LIB_DES=y
  FILES:=$(LINUX_DIR)/drivers/crypto/stm32/stm32-cryp.ko
  AUTOLOAD:=$(call AutoProbe,stm32-cryp)
  $(call AddDepends/crypto,@TARGET_stm32 +kmod-crypto-hash +kmod-crypto-des +kmod-crypto-engine)
endef

$(eval $(call KernelPackage,stm32-cryp))


define KernelPackage/stm32-dac
  TITLE:=STM32 DAC
  DEPENDS:=@TARGET_stm32
  KCONFIG:=CONFIG_STM32_DAC_CORE \
	   CONFIG_STM32_DAC
  FILES:=$(LINUX_DIR)/drivers/iio/dac/stm32-dac-core.ko \
	 $(LINUX_DIR)/drivers/iio/dac/stm32-dac.ko
  AUTOLOAD:=$(call AutoProbe,stm32-dac-core stm32-dac)
  $(call AddDepends/iio,@TARGET_stm32)
endef

$(eval $(call KernelPackage,stm32-dac))


define KernelPackage/stm32-csi
  TITLE:=STM32 Camera Serial Interface (CSI) support
  KCONFIG:=CONFIG_VIDEO_STM32_CSI
  FILES:=$(LINUX_DIR)/drivers/media/platform/st/stm32/stm32-csi.ko
  AUTOLOAD:=$(call AutoProbe,stm32-csi)
  $(call AddDepends/video,@TARGET_stm32_stm32mp2 +kmod-video-fwnode)
endef

$(eval $(call KernelPackage,stm32-csi))


define KernelPackage/stm32-dcmi
  TITLE:=STM32 Digital Camera Memory Interface support
  KCONFIG:=CONFIG_VIDEO_STM32_DCMI
  FILES:=$(LINUX_DIR)/drivers/media/platform/st/stm32/stm32-dcmi.ko
  AUTOLOAD:=$(call AutoProbe,stm32-dcmi)
  $(call AddDepends/video,@TARGET_stm32 +kmod-video-videobuf2 +kmod-video-dma-contig +kmod-video-async +kmod-video-fwnode)
endef

$(eval $(call KernelPackage,stm32-dcmi))


define KernelPackage/stm32-dcmipp
  TITLE:=STM32 Digital Camera Memory Interface Pixel Processor (DCMIPP) support
  KCONFIG:=CONFIG_VIDEO_STM32_DCMIPP
  FILES:=$(LINUX_DIR)/drivers/media/platform/st/stm32/stm32-dcmipp/stm32-dcmipp.ko
  AUTOLOAD:=$(call AutoProbe,stm32-dcmipp)
  $(call AddDepends/video,@TARGET_stm32 +kmod-video-videobuf2 +kmod-video-dma-contig +kmod-video-fwnode)
endef

$(eval $(call KernelPackage,stm32-dcmipp))


define KernelPackage/stm32-dfsdm-adc
  TITLE:=STM32 DFSDM ADC
  KCONFIG:=CONFIG_STM32_DFSDM_CORE \
	   CONFIG_STM32_DFSDM_ADC
  FILES:=$(LINUX_DIR)/drivers/iio/adc/stm32-dfsdm-core.ko \
	 $(LINUX_DIR)/drivers/iio/adc/stm32-dfsdm-adc.ko
  AUTOLOAD:=$(call AutoProbe,stm32-dfsdm-core stm32-dfsdm-adc)
  $(call AddDepends/iio,@TARGET_stm32 +kmod-stm32-timer-trigger +kmod-industrialio-triggered-buffer \
	  +kmod-industrialio-hw-consumer +kmod-industrialio-backend)
endef

$(eval $(call KernelPackage,stm32-dfsdm-adc))


define KernelPackage/stm32-hash
  SUBMENU:=$(CRYPTO_MENU)
  TITLE:=Support for STM32 hash accelerators
  DEPENDS:=@TARGET_stm32 \
	   +kmod-crypto-md5 \
	   +kmod-crypto-sha1 \
	   +kmod-crypto-sha256 \
	   +kmod-crypto-sha3 \
	   +kmod-crypto-rsa
  KCONFIG:=CONFIG_CRYPTO_DEV_STM32_HASH \
	   CONFIG_CRYPTO_ENGINE=y \
  FILES:=$(LINUX_DIR)/drivers/crypto/stm32/stm32-hash.ko
  AUTOLOAD:=$(call AutoProbe,stm32-hash)
endef

$(eval $(call KernelPackage,stm32-hash))


define KernelPackage/stm32-mdf-adc
  TITLE:=STMicroelectronics STM32 MDF adc
  KCONFIG:=CONFIG_STM32_MDF_ADC
  FILES:=$(LINUX_DIR)/drivers/iio/adc/stm32-mdf-adc.ko
  $(call AddDepends/iio,@TARGET_stm32_stm32mp2 +kmod-stm32-mdf-core +kmod-industrialio-backend \
	  +kmod-industrialio-triggered-buffer +kmod-stm32-timer-trigger)
endef

$(eval $(call KernelPackage,stm32-mdf-adc))


define KernelPackage/stm32-mdf-core
  TITLE:=STMicroelectronics STM32 MDF core
  KCONFIG:=CONFIG_STM32_MDF_CORE
  FILES:=$(LINUX_DIR)/drivers/iio/adc/stm32-mdf-core.ko \
	 $(LINUX_DIR)/drivers/iio/adc/stm32-mdf-serial.ko
  AUTOLOAD:=$(call AutoProbe,stm32-mdf-core stm32-mdf-serial)
  $(call AddDepends/iio,@TARGET_stm32_stm32mp2)
endef

$(eval $(call KernelPackage,stm32-mdf-core))


define KernelPackage/stm32-timers
  TITLE:=STM32 Timers
  DEPENDS:=@TARGET_stm32 +kmod-mfd
  SUBMENU:=$(OTHER_MENU)
  KCONFIG:=CONFIG_MFD_STM32_TIMERS
  FILES:=$(LINUX_DIR)/drivers/mfd/stm32-timers.ko
  AUTOLOAD:=$(call AutoProbe,stm32-timers)
endef

$(eval $(call KernelPackage,stm32-timers))


define KernelPackage/stm32-timer-trigger
  TITLE:=STM32 Timer Trigger
  KCONFIG:=CONFIG_IIO_STM32_TIMER_TRIGGER
  FILES:=$(LINUX_DIR)/drivers/iio/trigger/stm32-timer-trigger.ko
  AUTOLOAD:=$(call AutoProbe,stm32-timer-trigger)
  $(call AddDepends/iio,@TARGET_stm32 +kmod-stm32-timers)
endef

$(eval $(call KernelPackage,stm32-timer-trigger))


define KernelPackage/stm32-thermal
  SUBMENU:=$(OTHER_MENU)
  TITLE:=Thermal framework support on STMicroelectronics STM32 series of SoCs
  KCONFIG:=CONFIG_STM32_THERMAL
  DEPENDS:=@TARGET_stm32_stm32mp1 +kmod-thermal
  FILES:=$(LINUX_DIR)/drivers/thermal/st/stm_thermal.ko
  AUTOLOAD:=$(call AutoProbe,stm_thermal)
endef

$(eval $(call KernelPackage,stm32-thermal))


define KernelPackage/st-thermal
  SUBMENU:=$(OTHER_MENU)
  TITLE:=Thermal sensors on STMicroelectronics STi series of SoCs
  KCONFIG:=CONFIG_ST_THERMAL \
	   CONFIG_ST_THERMAL_MEMMAP
  DEPENDS:=@TARGET_stm32 +kmod-thermal
  FILES:=$(LINUX_DIR)/drivers/thermal/st/st_thermal.ko \
	 $(LINUX_DIR)/drivers/thermal/st/st_thermal_memmap.ko
  AUTOLOAD:=$(call AutoProbe,st_thermal st_thermal_memmap)
endef

$(eval $(call KernelPackage,st-thermal))


define KernelPackage/usb-dwc3-stm32
  TITLE:=STM32 DWC3 support
  KCONFIG:=CONFIG_USB_DWC3_STM32
  FILES:=$(LINUX_DIR)/drivers/usb/dwc3/dwc3-stm32.ko
  AUTOLOAD:=$(call AutoProbe,dwc3-stm32)
  $(call AddDepends/usb,@TARGET_stm32 +kmod-usb-dwc3)
endef

$(eval $(call KernelPackage,usb-dwc3-stm32))


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

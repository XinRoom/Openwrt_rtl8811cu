#
# referenced from immortalwrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8821cu
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/morrownr/8821cu-20210118
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-05-20
PKG_SOURCE_VERSION:=7033001f95501fbd45c99360a473bf0a7b001656
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8821cu
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8811CU/RTL8821CU support
  DEPENDS:=+kmod-cfg80211 +kmod-mac80211 +kmod-usb-core +@DRIVER_11N_SUPPORT +@DRIVER_11AC_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/rtl8821cu.ko
  AUTOLOAD:=$(call AutoProbe,rtl8821cu)
  MODPARAMS:="rtw_drv_log_level=4 rtw_led_ctrl=1 rtw_vht_enable=2 rtw_power_mgnt=1 rtw_dfs_region_domain=0 rtw_country_code=US"
  PROVIDES:=kmod-rtl8821cu
endef

NOSTDINC_FLAGS = \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/autoconf.h \
	-include backport/backport.h

EXTRA_KCONFIG:= \
	CONFIG_RTL8821CU=m \
	USER_MODULE_NAME=rtl8821cu

ifeq ($(ARCH),aarch64)
	EXTRA_KCONFIG += CONFIG_MP_VHT_HW_TX_MODE=n
endif

EXTRA_CFLAGS:= \
	-DRTW_SINGLE_WIPHY \
	-DRTW_USE_CFG80211_STA_EVENT \
	-DCONFIG_IOCTL_CFG80211 \
	-DCONFIG_CONCURRENT_MODE \
	-DBUILD_OPENWRT

ifeq ($(BOARD),x86)
	EXTRA_CFLAGS += -mhard-float
endif

MAKE_OPTS:= \
	$(KERNEL_MAKE_FLAGS) \
	M="$(PKG_BUILD_DIR)" \
	NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
	USER_EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage,rtl8821cu))
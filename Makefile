include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-smsforward
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=$(User_Name)

LUCI_TITLE:=LuCI support for SMS Forwarding (Serial/ModemManager)
LUCI_DEPENDS:=+sms-tool +modemmanager +mmcli +msmtp +libuci-lua
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	chmod +x /usr/bin/sms_handler.sh
	chmod +x /etc/init.d/smsforward
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature

#!/bin/sh

# =========================================================
# luci-app-smsforward 一键安装脚本
# =========================================================

GITHUB_RAW="https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main"

echo "开始安装 luci-app-smsforward..."

# 1. 安装必要依赖
echo "正在安装依赖项: sms-tool, modemmanager, msmtp, ca-bundle..."
opkg update
opkg install sms-tool modemmanager mmcli msmtp ca-bundle luci-base luci-compat

# 2. 创建目录结构
echo "正在创建目录..."
mkdir -p /usr/bin
mkdir -p /etc/config
mkdir -p /etc/init.d
mkdir -p /usr/lib/lua/luci/controller/modem
mkdir -p /usr/lib/lua/luci/model/cbi/modem

# 3. 下载文件并放置到对应位置
echo "正在从 GitHub 下载最新代码..."

# 后端脚本
wget -qO /usr/bin/sms_handler.sh ${GITHUB_RAW}/root/usr/bin/sms_handler.sh
chmod +x /usr/bin/sms_handler.sh

# 启动脚本
wget -qO /etc/init.d/smsforward ${GITHUB_RAW}/root/etc/init.d/smsforward
chmod +x /etc/init.d/smsforward

# 配置文件 (如果不存则下载，避免覆盖用户已有配置)
if [ ! -f "/etc/config/smsforward" ]; then
    wget -qO /etc/config/smsforward ${GITHUB_RAW}/root/etc/config/smsforward
fi

# LuCI 界面文件
wget -qO /usr/lib/lua/luci/controller/modem/smsforward.lua ${GITHUB_RAW}/luasrc/controller/modem/smsforward.lua
wget -qO /usr/lib/lua/luci/model/cbi/modem/smsforward.lua ${GITHUB_RAW}/luasrc/model/cbi/modem/smsforward.lua

# 4. 刷新 LuCI 缓存并启动服务
echo "正在清理 LuCI 缓存..."
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

echo "正在启动服务..."
/etc/init.d/smsforward enable
/etc/init.d/smsforward start

echo "----------------------------------------------------------"
echo "✅ 安装成功！"
echo "请登录 OpenWrt 后台，进入 '调制解调器' -> '短信转发' 进行配置。"
echo "----------------------------------------------------------"

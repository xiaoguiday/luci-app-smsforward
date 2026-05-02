#!/bin/sh

# =========================================================
# luci-app-smsforward 一键卸载脚本
# =========================================================

echo "开始卸载 luci-app-smsforward..."

# 1. 停止并禁用服务
if [ -f "/etc/init.d/smsforward" ]; then
    echo "正在停止后台服务..."
    /etc/init.d/smsforward stop
    /etc/init.d/smsforward disable
fi

# 2. 删除核心脚本与启动项
echo "正在删除脚本文件..."
rm -f /usr/bin/sms_handler.sh
rm -f /etc/init.d/smsforward

# 3. 删除 LuCI 界面文件
echo "正在删除 LuCI 界面文件..."
rm -f /usr/lib/lua/luci/controller/modem/smsforward.lua
rm -f /usr/lib/lua/luci/model/cbi/modem/smsforward.lua

# 4. 删除配置文件 (可选：你可以决定是否保留用户配置)
# 如果想完全抹除，取消下面这行的注释:
# rm -f /etc/config/smsforward

# 5. 清理缓存以刷新菜单
echo "正在清理缓存..."
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
rm -f /tmp/sms_forward/raw_recv.txt
rm -f /tmp/msmtp_sms.conf

echo "----------------------------------------------------------"
echo "✅ 卸载完成！"
echo "提示：依赖包 (msmtp, sms-tool 等) 未自动删除，如需移除请手动执行 opkg remove。"
echo "----------------------------------------------------------"

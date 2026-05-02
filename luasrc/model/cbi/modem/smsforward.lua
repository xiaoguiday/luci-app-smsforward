local sys = require "luci.sys"

m = Map("smsforward", translate("短信转发配置"), translate("支持串口 (sms-tool) 或 ModemManager (mmcli) 模式"))

-- 基础配置区
s = m:section(TypedSection, "smsforward", translate("基础配置"))
s.anonymous = true

-- --- 状态显示（增强版：进程全路径检测 + 强制刷新） ---
st = s:option(DummyValue, "_status", translate("当前运行状态"))
st.rawhtml = true
function st.cfgvalue(self, section)
    -- 优化后的检测逻辑：不仅找脚本名，还检查是否在后台 shell 循环中运行
    -- 使用 ps 配合 grep 查找，比 pidof 更适合这种 while 循环进程
    local check_cmd = "ps -w | grep 'sms_handler.sh' | grep -v 'grep' | awk '{print $1}' | head -n 1"
    local pid = sys.exec(check_cmd)
    
    -- 增加一个刷新按钮，方便手动同步状态
    local btn_refresh = [[<input type="button" class="cbi-button cbi-button-link" value="🔄 刷新状态" onclick="location.reload();" style="margin-left:10px; text-decoration:none;" />]]
    
    if pid and pid ~= "" then
        pid = pid:gsub("%s+", "") -- 去除换行符
        return "<span style='color:white; background-color:green; padding:2px 6px; border-radius:4px; font-weight:bold;'>✔ 运行中</span> (PID: " .. pid .. ")" .. btn_refresh
    else
        return "<span style='color:white; background-color:red; padding:2px 6px; border-radius:4px; font-weight:bold;'>❌ 已停止</span>" .. btn_refresh
    end
end
-- ------------------------------------------

e = s:option(Flag, "enabled", translate("启用转发"))
e.rmempty = false

dev = s:option(Value, "device", translate("模块端口/模式"), translate("串口填路径(如/dev/ttyUSB2)，MM模式填 ModemManager"))
dev.default = "/dev/ttyUSB2"
dev:value("/dev/ttyUSB2")
dev:value("/dev/ttyUSB3")
dev:value("mm", "ModemManager (自动识别)")

srv = s:option(Value, "server", translate("SMTP 服务器"))
srv.placeholder = "smtp.qq.com"

prt = s:option(Value, "port", translate("端口"))
prt.default = "465"

usr = s:option(Value, "user", translate("账号"))
pw = s:option(Value, "password", translate("密码"))
pw.password = true

target = s:option(Value, "target_email", translate("接收邮箱"))
sender = s:option(Value, "sender_email", translate("发送邮箱"))

iv = s:option(Value, "interval", translate("检查频率 (秒)"))
iv.default = "60"

-- 保存并应用时的逻辑优化
m.on_after_commit = function(self)
    -- 延迟 1 秒重启，给系统留出处理 UCI 写入的时间，减少显示状态冲突
    os.execute("sleep 1 && /etc/init.d/smsforward restart >/dev/null 2>&1 &")
end

return m

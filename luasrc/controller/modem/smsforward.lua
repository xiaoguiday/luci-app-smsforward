module("luci.controller.modem.smsforward", package.seeall)

function index()
    -- 只有当配置文件存在时才显示菜单，防止系统报错
    if not nixio.fs.access("/etc/config/smsforward") then
        return
    end

    -- 注册菜单项
    -- 这里的 cbi("modem/smsforward") 对应 luasrc/model/cbi/modem/smsforward.lua
    entry({"admin", "modem", "smsforward"}, cbi("modem/smsforward"), _("短信转发"), 10).dependent = true
end

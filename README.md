# luci-app-smsforward

![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-OpenWrt%20%2F%20ImmortalWrt-orange.svg)
![Maintainer](https://img.shields.io/badge/Maintainer-xiaoguiday-green.svg)

这是一个为 **OpenWrt / ImmortalWrt** 设计的短信转发插件。  
它能够实时监控 4G / 5G 模块收到的短信，并通过 SMTP 协议转发到您的邮箱。

<img width="800" alt="luci-app-smsforward 界面预览" src="https://github.com/user-attachments/assets/eadd92cb-86fb-42a9-b36d-6400073fd909" />

---

## 🌟 项目亮点

- 🚀 **双模式自动切换**  
  完美兼容传统串口模式（sms-tool）与现代 ModemManager（mmcli）模式

- 📩 **长短信深度优化**  
  针对 mmcli 输出重构解析逻辑，解决长短信断裂与乱码问题

- 🧹 **纯净正文提取**  
  自动过滤 mmcli 的 Properties 等冗余信息，仅保留短信正文

- 📊 **实时监控面板**  
  LuCI UI 内置进程状态检测，支持 PID 显示与一键刷新

- 🛡️ **安全去重机制**  
  基于 MD5 指纹校验，避免重复短信邮件推送

---

## 🏗️ 系统架构

- **前端（LuCI）**  
  基于 Lua / CBI 构建的可视化配置界面

- **后台（procd）**  
  作为系统守护进程运行，支持异常自动重启

- **引擎（Shell）**  
  负责短信捕获、设备通信、解析与逻辑路由

- **传输（msmtp）**  
  轻量 SMTP 客户端，支持 SSL / TLS 加密发送

---

## ⚡ 快速安装（免编译）

适用于已刷 OpenWrt / ImmortalWrt 固件用户：

### 一键安装
```bash
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/install.sh | sh
一键卸载
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/uninstall.sh | sh
🛠️ 编译方式
1. 克隆源码
cd package
git clone https://github.com/xiaoguiday/luci-app-smsforward.git
2. 更新 feeds
cd ..
./scripts/feeds update -a
./scripts/feeds install -a
3. 进入菜单配置
make menuconfig

路径：

LuCI -> 3. Applications -> luci-app-smsforward

按空格选择 *

4. 编译
make package/luci-app-smsforward/compile V=s
⚙️ 使用说明
配置项	说明
设备端口	/dev/ttyUSBX 或 mm（ModemManager 模式）
SMTP服务器	如 smtp.qq.com / smtp.gmail.com
SMTP端口	推荐 465 (SSL) 或 587 (STARTTLS)
密码	邮箱授权码（不是登录密码）
检查间隔	建议 30–60 秒
📦 核心依赖
sms-tool
modemmanager / mmcli
msmtp
ca-bundle（SSL 证书支持）
🤝 鸣谢

本项目针对以下设备进行了优化适配：

Quectel RM520N-GL
Quectel RG200U 系列
OpenWrt / ImmortalWrt 环境短信解析优化
⭐ 支持项目

如果这个项目对你有帮助，请给一个 Star ⭐ 支持作者继续更新。

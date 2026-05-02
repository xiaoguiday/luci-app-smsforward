Markdown
# luci-app-smsforward

这是一个为 OpenWrt/ImmortalWrt 设计的短信转发插件，支持将收到的短信通过邮件 (SMTP) 转发至指定邮箱。

<img width="1001" height="726" alt="image" src="https://github.com/user-attachments/assets/eadd92cb-86fb-42a9-b36d-6400073fd909" />


## 🌟 项目亮点

*   **双模式支持**：完美兼容传统串口模式 (`sms-tool`) 和现代的 `ModemManager` (`mmcli`) 模式。
*   **长短信优化**：专门针对 `ModemManager` 模式下的长短信逻辑进行了优化，能够完整提取被分割的长短信内容。
*   **系统信息过滤**：自动截断 `mmcli` 输出中的 Properties 系统冗余信息，仅保留纯净短信正文。
*   **实时状态显示**：LuCI 界面内置进程监控，可实时查看转发后台的运行状态及 PID。
*   **安全去重**：内置 MD5 指纹去重算法，防止同一条短信被重复转发。

## 🏗️ 系统架构

该项目由以下几个核心部分组成：

1.  **LuCI 界面** (Lua/CBI): 提供用户配置入口及运行状态显示。
2.  **守护进程** (procd): 负责 24 小时后台循环监控。
3.  **核心处理脚本** (Shell): 执行短信提取、多行正文拼接、Properties 过滤及邮件调用逻辑。
4.  **邮件引擎** (msmtp): 负责与 SMTP 服务器进行安全通信。

## 免编译一键安装（在openwrt直接执行）
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/install.sh | sh
## 一键卸载
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/uninstall.sh | sh


## 🛠️ 编译方式

### 1. 准备工作
将本仓库克隆到你的 OpenWrt 源码目录下的 `package` 目录中：

```bash
cd openwrt/package
git clone [https://github.com/xiaoguiday/luci-app-smsforward.git](https://github.com/xiaoguiday/luci-app-smsforward.git)
2. 更新 Feeds
Bash
cd ..
./scripts/feeds update -a && ./scripts/feeds install -a
3. 配置菜单
执行 make menuconfig，在以下路径找到并选中：
LuCI -> 3. Applications -> luci-app-smsforward

4. 开始编译
Bash
make package/luci-app-smsforward/compile V=s
📦 依赖项
编译系统会自动处理以下依赖，请确保你的固件包含这些包：

sms-tool (用于串口模式)

modemmanager & mmcli (用于 MM 模式)

msmtp (邮件发送核心)

ca-bundle (用于处理 SMTP 的 SSL/TLS 证书)

⚙️ 使用说明
模式选择：

如果你使用传统的 /dev/ttyUSB 端口，请直接填写路径。

如果你使用 ModemManager (推荐用于 Quectel 5G 模块，如 RM520N-GL, RG200U-CN)，请在端口处填入 mm。

状态监控：

界面会显示 ✔ 运行中 或 ❌ 已停止。如果状态显示不及时，可以点击界面上的“刷新状态”按钮。

邮件配置：

建议使用 465 或 587 端口。对于 Gmail/QQ 邮箱，请使用 授权码 而非登录密码。

🤝 鸣谢与支持
本项目在开发过程中得到了技术社区的反馈支持，特别针对 Quectel 系列模块在 OpenWrt 环境下的短信解析进行了深度调优。

如果你觉得有用，请点一个 Star！

Maintainer: xiaoguiday

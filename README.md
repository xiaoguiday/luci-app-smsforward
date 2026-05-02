 luci-app-smsforward

![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-OpenWrt%20%2F%20ImmortalWrt-orange.svg)
![Maintainer](https://img.shields.io/badge/Maintainer-xiaoguiday-green.svg)

这是一个为 OpenWrt/ImmortalWrt 设计的短信转发插件。它能够实时监控 5G/4G 模块收到的短信，并通过 SMTP 协议转发至您的电子邮箱。

<img width="800" alt="luci-app-smsforward 界面预览" src="https://github.com/user-attachments/assets/eadd92cb-86fb-42a9-b36d-6400073fd909" />

---

## 🌟 项目亮点

*   **🚀 双模式自动切换**：完美兼容传统串口模式 (`sms-tool`) 与现代 `ModemManager` (`mmcli`) 模式。
*   **📩 长短信深度优化**：专门针对 `ModemManager` 模式重构了解析逻辑，解决长短信内容断裂、乱码问题。
*   **🧹 纯净正文提取**：自动过滤 `mmcli` 输出中的 Properties 系统冗余信息，仅发送有效的短信正文。
*   **📊 实时监控面板**：UI 界面内置进程状态检测，支持 PID 显示及一键状态刷新。
*   **🛡️ 安全去重逻辑**：基于 MD5 的指纹校验，确保在网络波动或模块重置时，不会收到重复的转发邮件。

## 🏗️ 系统架构

*   **前端 (LuCI)**: 基于 Lua/CBI 构建，提供直观的配置界面。
*   **后台 (procd)**: 注册为系统守护进程，支持异常退出自动重启。
*   **引擎 (Shell)**: 负责硬件交互、短信捕获、正则解析及逻辑路由。
*   **传输 (msmtp)**: 轻量化 SMTP 客户端，支持 SSL/TLS 安全链路。

---

## ⚡ 快速安装 (免编译)

如果您使用的是现成的固件，直接在 SSH 终端执行以下命令即可：

### 一键安装
```bash
wget -qO- [https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/install.sh](https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/install.sh) | sh
一键卸载Bashwget -qO- [https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/uninstall.sh](https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/uninstall.sh) | sh
🛠️ 编译方式如果您希望将插件集成到固件中，请参考以下步骤：1. 准备工作将本仓库克隆到您的 OpenWrt 源码目录下的 package 目录：Bashcd package
git clone [https://github.com/xiaoguiday/luci-app-smsforward.git](https://github.com/xiaoguiday/luci-app-smsforward.git)
2. 更新 FeedBashcd ..
./scripts/feeds update -a && ./scripts/feeds install -a
3. 配置菜单执行 make menuconfig，依次进入：LuCI -> 3. Applications -> luci-app-smsforward (按空格键选中 *)4. 执行编译Bashmake package/luci-app-smsforward/compile V=s
⚙️ 使用说明配置项说明设备端口传统串口填 /dev/ttyUSBX；使用 ModemManager (Quectel 5G 推荐) 请填 mmSMTP 服务器如 smtp.qq.com 或 smtp.gmail.com端口推荐使用 465 (SSL) 或 587 (STARTTLS)密码务必使用邮箱授权码，而非邮箱登录密码检查频率建议设置在 30-60 秒，兼顾实时性与系统开销📦 核心依赖插件会自动处理依赖，但请确保您的软件源配置正确：sms-tool / modemmanager / mmclimsmtp / ca-bundle (SSL 证书支持)🤝 鸣谢与支持特别针对 Quectel 系列模块（RM520N-GL, RG200U-CN 等）在 OpenWrt 环境下的短信解析进行了深度调优。觉得好用？请点一个 Star ⭐ 给作者以鼓励！Maintainer: xiaoguiday
---

### 优化点说明：
1.  **增加状态徽章 (Badges)**：在顶部增加了 License、Platform 等标签，项目显得更正规。
2.  **表格化配置说明**：将原本杂乱的使用说明整理成表格，用户阅读效率更高。
3.  **代码块高亮修正**：统一了代码块的风格，并修正了原本 README 中部分 Bash 命令格式不规范的问题。
4.  **可视化增强**：使用了更多的 Emoji 符号来引导视觉重心，减少纯文字的枯燥感。
5.  **安装命令精简**：突出了一键脚本的使用，这是大部分非开发者用户最需要的部分。

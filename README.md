# luci-app-smsforward

![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-OpenWrt%20%2F%20ImmortalWrt-orange.svg)
![Maintainer](https://img.shields.io/badge/Maintainer-xiaoguiday-green.svg)

这是一个为 **OpenWrt / ImmortalWrt** 设计的短信转发插件。  
它能够实时监控 4G / 5G 模块收到的短信，并通过 SMTP 协议转发到邮箱。

---

## 🌟 项目亮点

- 🚀 双模式自动切换（sms-tool / mmcli）
- 📩 长短信优化（解决断裂与乱码）
- 🧹 自动过滤 mmcli 冗余信息
- 📊 LuCI 实时状态监控
- 🛡️ MD5 去重防重复推送

---

## 🏗️ 系统架构

- LuCI 前端（Lua / CBI）
- procd 守护进程
- Shell 短信解析引擎
- msmtp 邮件发送

---

## ⚡ 快速安装（免编译）

### 一键安装

```bash
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/install.sh | sh
```

### 一键卸载

```bash
wget -qO- https://raw.githubusercontent.com/xiaoguiday/luci-app-smsforward/main/uninstall.sh | sh
```

---

## 🛠️ 编译方式

### 1. 克隆源码

```bash
cd package
git clone https://github.com/xiaoguiday/luci-app-smsforward.git
```

### 2. 更新 feeds

```bash
cd ..
./scripts/feeds update -a
./scripts/feeds install -a
```

### 3. 菜单配置

```bash
make menuconfig
```

路径：

```
LuCI -> 3. Applications -> luci-app-smsforward
```

### 4. 编译

```bash
make package/luci-app-smsforward/compile V=s
```

---

## ⚙️ 使用说明

| 项目 | 说明 |
|------|------|
| 设备端口 | /dev/ttyUSBX 或 mm |
| SMTP服务器 | smtp.qq.com / smtp.gmail.com |
| SMTP端口 | 465 / 587 |
| 密码 | 邮箱授权码 |
| 检查间隔 | 30–60 秒 |

---

## 📦 依赖

- sms-tool
- modemmanager / mmcli
- msmtp
- ca-bundle

---

## 🤝 鸣谢

Quectel RM520N-GL / RG200U 系列优化适配  
OpenWrt / ImmortalWrt 环境测试支持

---

## ⭐ Star

如果有帮助，请点个 Star ⭐

# Claude Code Notification Plugin

桌面通知插件，在以下场景发送系统通知（仅当终端在后台时触发）：

- **权限请求** - 需要用户确认权限时
- **任务完成** - Claude 完成任务时

## 安装

```bash
# 1. 在 Claude Code 输入框中添加市场
/plugin marketplace add https://github.com/Oreo992/claude-notification

# 2. 安装插件（根据你的系统选择）
/plugin install windows@claude-notification    # Windows
/plugin install unix@claude-notification       # macOS/Linux
```

> **注意**: 安装完成后需要重启 Claude Code 才能生效。

## 插件列表

| 插件 | 平台 | 说明 |
|------|------|------|
| `windows` | Windows 10/11 | PowerShell 实现，无需额外依赖 |
| `unix` | macOS/Linux | macOS 使用 osascript，Linux 使用 notify-send |

## 配置（可选）

插件支持自定义配置。**直接告诉 AI 你想要什么配置即可**，例如：

- "帮我配置 Bark 通知"
- "我想让通知显示时间长一点"
- "只用 Bark 推送，不要系统通知"

AI 会自动创建配置文件 `.claude/claude-notification.local.md`。

### 手动配置

如果你想手动配置，在项目根目录创建 `.claude/claude-notification.local.md`：

```markdown
---
bark_url: "https://api.day.app/your-key"
bark_only: false
timeout: 3000
---
```

### 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `bark_url` | string | 空 | Bark 推送地址 |
| `bark_only` | boolean | false | 设为 true 则只使用 Bark，不显示系统通知 |
| `timeout` | number | 3000 | 通知显示时长(毫秒)，Windows/Linux 有效 |

## Bark 推送

[Bark](https://github.com/Finb/Bark) 是一个 iOS 推送服务，优势是通知会持久保留在通知中心。

### 安装 Bark

1. 在 App Store 下载 Bark 应用
2. 打开应用获取推送 URL（格式：`https://api.day.app/your-key`）
3. 告诉 AI："帮我配置 Bark 通知"，提供你的 URL

### AI 主动发送通知

AI 可以在完成重要任务时主动发送通知。插件提供了完整的 Bark 推送脚本，支持：

- 标题和内容自定义
- 紧急通知（持续响铃30秒）
- 消息分组
- 自定义铃声
- 时效性通知
- 点击跳转 URL
- 自动复制内容

**示例场景：**
- 长时间构建完成
- 测试运行结束
- 代码审查完成
- 需要紧急确认

## 功能特点

- **智能检测** - 只在终端窗口处于后台时发送通知
- **多终端支持** - 能正确区分不同的终端窗口实例
- **项目路径** - 通知中显示当前项目的最后两级目录
- **Bark 支持** - 可选配置 iOS Bark 推送，支持持久通知
- **AI 集成** - AI 可以主动调用通知脚本发送提醒
- **丰富参数** - 支持紧急通知、消息分组、自定义铃声等

## 系统要求

### Windows
- Windows 10/11
- PowerShell 5.1+（系统自带）

### macOS
- macOS 10.14+
- 无需额外依赖

### Linux
- 需要安装 `libnotify`
- Ubuntu/Debian: `sudo apt install libnotify-bin`

## 插件结构

```
windows/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── notification-config/
│       ├── SKILL.md              # AI 技能定义
│       └── scripts/
│           ├── notify.ps1        # 系统通知脚本
│           └── bark.ps1          # Bark 推送脚本
└── hooks/
    └── hooks.json                # Hook 配置

unix/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── notification-config/
│       ├── SKILL.md
│       └── scripts/
│           ├── notify.sh
│           └── bark.sh
└── hooks/
    └── hooks.json
```

## 使用示例

### 自动通知（Hooks）

插件会在以下事件自动发送通知：
- 权限请求时
- 任务完成时

### AI 主动通知

AI 会在合适的时机主动发送通知，例如：

```
用户: "帮我运行测试，完成后通知我"
AI: [运行测试] → [测试完成] → [发送 Bark 通知]
```

### 手动调用脚本

你也可以直接调用脚本：

**Windows:**
```powershell
# 查看帮助
.\bark.ps1 -Help

# 发送通知
.\bark.ps1 -Url "https://api.day.app/xxx" -Message "任务完成"

# 紧急通知
.\bark.ps1 -Url "https://api.day.app/xxx" -Message "需要确认" -Call
```

**macOS/Linux:**
```bash
# 查看帮助
./bark.sh -h

# 发送通知
./bark.sh -u "https://api.day.app/xxx" -m "任务完成"

# 紧急通知
./bark.sh -u "https://api.day.app/xxx" -m "需要确认" -c
```

## 常见问题

**Q: 配置修改后不生效？**
A: 需要重启 Claude Code 才能生效。

**Q: 如何让通知持久保留？**
A: 使用 Bark 推送，iOS 通知中心会持久保留。

**Q: 如何发送紧急通知？**
A: 告诉 AI "发送紧急通知"，或使用 `-Call` / `-c` 参数。

**Q: 通知没有显示？**
A: 检查终端是否在前台，插件只在终端后台时发送通知。

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.1.0 (2026-01-31)
- ✨ 新增 Bark 推送支持
- ✨ 新增配置文件支持
- ✨ 新增 AI 主动通知能力
- ✨ 新增完整的 Bark 参数支持（紧急通知、分组、铃声等）
- 🔧 优化插件结构，符合 Claude Code 规范
- 📝 完善文档和使用示例

### v1.0.0
- 🎉 初始版本
- ✅ Windows/macOS/Linux 支持
- ✅ 权限请求和任务完成通知

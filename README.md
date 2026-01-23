# Claude Code Notification Plugin

桌面通知插件市场，在以下场景发送系统通知（仅当终端在后台时触发）：

- **权限请求** - 需要用户确认权限时
- **空闲等待** - Claude 等待用户输入
- **任务完成** - Claude 完成任务时

## 安装

```bash
# 1. 添加市场
plugin marketplace add Oreo992/claude-notification

# 2. 安装插件（根据你的系统选择）
plugin install windows@claude-notification    # Windows
plugin install unix@claude-notification       # macOS/Linux
```

> **注意**: 安装完成后需要重启 Claude Code 才能生效。

## 插件列表

| 插件 | 平台 | 说明 |
|------|------|------|
| `windows` | Windows 10/11 | PowerShell 实现，无需额外依赖 |
| `unix` | macOS/Linux | macOS 使用 osascript，Linux 使用 notify-send |

## 功能特点

- 智能检测：只在终端窗口处于后台时发送通知
- 多终端支持：能正确区分不同的终端窗口实例
- 项目路径：通知中显示当前项目的最后两级目录

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

## 许可证

MIT

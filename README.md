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


## 更新
如果您已经安装过此插件，请使用以下命令更新插件版本
```bash
/plugin marketplace update claude-notification
```
<img width="745" height="181" alt="image" src="https://github.com/user-attachments/assets/4bbdb377-4e9b-4a04-9553-cd536f7c9a4c" />

当提示更新完毕，重启Claude Code。

## 初始化/配置

此插件支持自定义配置和对应的Skills。
首次使用建议运行
```bash
/notification-config
```
跟随Claude，完成通知插件的配置
<img width="1341" height="413" alt="image" src="https://github.com/user-attachments/assets/396361a3-a550-4d9c-9c04-48070bcb976c" />



后续你也可以使用此Skills，对通知配置进行更改，如：
- "帮我配置 Bark 通知"
- "只用 Bark 推送，不要系统通知"
- "我想终端在前台时也收到通知"

示例:

<img width="899" height="450" alt="image" src="https://github.com/user-attachments/assets/5040723f-e7ff-4417-9435-cad140e7991b" />


AI 会自动创建配置文件 `.claude/claude-notification.local.md`，并询问是否要在项目的 `CLAUDE.md` 中添加通知功能，让 AI 能够在完成任务后主动发送通知。


## 让 AI 主动发送通知

这通常会在初始化时，Claude会主动询问您是否配置，如果未询问，您也可以通过
```bash
/notification-config 给你自己加上通知的功能,到全局的CLAUDE.md中
```
<img width="1144" height="912" alt="image" src="https://github.com/user-attachments/assets/a31bf2a8-177d-45ec-950c-8fe047e04f68" />

支持的通知场景：
- 用户明确要求："完成后通知我"、"用 bark 通知我"
- 长时间任务完成：构建、测试、部署等
- 重要里程碑：PR 创建、代码审查完成
- 需要关注的错误：构建失败、测试不通过


示例：
<img width="1581" height="276" alt="image" src="https://github.com/user-attachments/assets/18e73474-d577-45d3-8399-f447b56495b3" />

收到的提示如下：

<img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/4af4bc54-afa2-49a9-a54f-6c8a9bb44960" />


详细配置指南也可以查看 [NOTIFICATION_SETUP.md](./NOTIFICATION_SETUP.md)。

### 手动配置

如果你想手动配置，在项目根目录创建 `.claude/claude-notification.local.md`：

```markdown
---
bark_url: "https://api.day.app/your-key"
wechat_token: "your-wechat-token"
bark_only: false
always_notify: false
---
```

### 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `bark_url` | string | 空 | Bark 推送地址 |
| `wechat_token` | string | 空 | 微信推送 Token（Server酱） |
| `bark_only` | boolean | false | 设为 true 则只使用 Bark，不显示系统通知 |
| `always_notify` | boolean | false | 设为 true 则始终通知，即使终端在前台 |

## 微信推送

[Server酱](https://xtuis.cn/) 是一个微信推送服务，可以将通知推送到微信，方便在手机上接收。

### 配置微信推送

1. 访问 [https://xtuis.cn/](https://xtuis.cn/)
2. 微信扫码关注公众号
3. 获取你的专属 Token
4. 告诉 AI："帮我配置微信通知"，提供你的 Token

配置完成后，Token 会保存在 `.claude/claude-notification.local.md` 文件中，AI 可以直接调用发送通知。

### AI 主动发送通知

AI 可以在完成重要任务时主动发送微信通知。插件提供了完整的微信推送脚本，支持：

- 标题和内容自定义
- 详细描述信息
- 持久保留在微信中

**示例场景：**
- 长时间构建完成
- 测试运行结束
- 代码审查完成
- 重要任务完成提醒

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

- **智能检测** - 只在终端窗口处于后台时发送通知（可配置）
- **多终端支持** - 能正确区分不同的终端窗口实例
- **终端识别** - 通知中显示终端名称，方便多终端场景识别
- **项目路径** - 通知中显示当前项目的最后两级目录
- **持久化通知** - 通知会进入系统通知中心并保留
  - Windows: 使用 Toast 通知 API，进入 Windows 通知中心
  - macOS: 原生支持，进入 macOS 通知中心
  - Linux: 大部分桌面环境支持（GNOME、KDE 等）
- **Bark 支持** - 可选配置 iOS Bark 推送，支持持久通知
- **微信推送** - 可选配置微信推送（Server酱），通知直达微信
- **AI 集成** - AI 可以主动调用通知脚本发送提醒
- **丰富参数** - 支持紧急通知、消息分组、自定义铃声等
- **灵活配置** - 支持前台通知、仅 Bark 推送等多种模式

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
│           ├── bark.ps1          # Bark 推送脚本
│           └── wechat.ps1        # 微信推送脚本
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
│           ├── bark.sh
│           └── wechat.sh
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

### v1.2.x (2026-02-02) - 稳定性与体验优化

> 从 v1.0 到 v1.2，插件从「被动通知」进化为「AI 主动推送」，让你真正解放双手。

#### 核心变化

| 痛点 | v1.0 | v1.2 |
|------|------|------|
| 只能等通知 | Hook 触发的被动通知 | AI 可主动推送，完成任务自动提醒 |
| 通知转瞬即逝 | Windows BalloonTip 几秒消失 | Toast API + Bark 持久保留 |
| 手机收不到 | 仅桌面通知 | Bark 推送到 iOS，随时随地收通知 |
| 配置繁琐 | 无配置，无法自定义 | `/notification-config` 一键配置 |
| 终端前台也弹 | 无法区分前后台 | 智能检测，后台才通知 |
| 多终端难区分 | 无终端标识 | 显示终端名称，一目了然 |

#### 详细更新

**v1.2.8** - 终端识别
- ✨ 通知中显示终端名称（如 `[Windows PowerShell]`），方便多终端场景识别
- 🔧 Windows 优先使用主窗口标题，macOS/Linux 自动检测终端类型

**v1.2.6** - 路径动态化
- 🔧 SKILL.md 使用 `{{PLUGIN_PATH}}` 占位符，版本更新无需手动改路径

**v1.2.5** - 移除无效配置
- 🗑️ 移除 `timeout` 配置项（Windows Toast 不支持自定义时长）
- 🐛 修复 PowerShell 脚本 UTF-8 BOM 编码问题，解决中文系统解析失败

**v1.2.4** - 通知持久化
- ✨ Windows 升级到 Toast 通知 API，通知进入系统通知中心
- ✨ 新增 `always_notify` 配置，支持前台也发通知
- 🐛 修复 Unix 脚本可执行权限

**v1.2.0 ~ v1.2.3** - AI 主动通知
- ✨ 新增 Bark iOS 推送支持，通知持久保留
- ✨ 新增 `/notification-config` Skills，对话式配置
- ✨ AI 可在完成任务后主动调用 bark.ps1/bark.sh 发送通知
- ✨ 支持紧急通知（`-Call`）、消息分组（`-Group`）、自定义铃声等
- 🔧 配置流程优化，避免重复询问
- 📝 自动生成 CLAUDE.md 通知配置模板

### v1.1.0 (2026-01-31) - Bark 集成
- ✨ 新增 Bark 推送支持
- ✨ 新增项目级配置文件 `.claude/claude-notification.local.md`
- 🔧 优化插件结构，符合 Claude Code 规范

### v1.0.0 - 初始版本
- 🎉 Windows/macOS/Linux 跨平台支持
- ✅ Hook 自动触发：权限请求、任务完成
- ✅ 智能前后台检测

---
name: notification-config
description: |
  This skill should be used when the user asks to "configure notifications", "set up Bark",
  "configure Bark push", "configure WeChat notifications", "make notifications persistent", "always notify",
  or mentions "Bark", "WeChat", "notification settings", "push notifications".
  Also use when AI needs to proactively send notifications after completing important tasks.
---

# Claude Notification Configuration and Usage

This plugin supports configuration and proactive notification sending.

## Configuration File

**Location**: `.claude/claude-notification.local.md` (project root)

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `bark_url` | string | empty | Bark push URL, e.g., `https://api.day.app/your-key` |
| `wechat_token` | string | empty | WeChat Token, get from https://xtuis.cn/ |
| `bark_only` | boolean | false | Set to true to use only Bark, skip system notifications |
| `always_notify` | boolean | false | Set to true to always notify, even when terminal is in foreground |

### Configuration Template

```markdown
---
bark_url: ""
wechat_token: ""
bark_only: false
always_notify: false
---
```

## Proactive Notification Sending

AI can call notification scripts at appropriate times.

### Available Scripts

Scripts are located in `scripts/` directory of this skill:

- **`scripts/notify.sh`** - System notification script
- **`scripts/bark.sh`** - Bark push script with full parameters
- **`scripts/wechat.sh`** - WeChat push script

### System Notification

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/notify.sh" "Title" "Content" "${CLAUDE_PROJECT_DIR}"
```

### Bark Push

Use `scripts/bark.sh` for rich push notifications:

```bash
# View help
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.sh" -h

# Simple push
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.sh" -u "URL" -m "Task completed"

# With title
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.sh" -u "URL" -t "Claude" -m "Code review done"

# Urgent (ring for 30s)
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.sh" -u "URL" -m "Urgent!" -c

# Grouped message
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.sh" -u "URL" -m "Build done" -g "build"
```

### Bark Parameters

| Parameter | Description |
|-----------|-------------|
| `-u, --url` | Bark server URL (required) |
| `-m, --message` | Push content (required) |
| `-t, --title` | Push title |
| `-g, --group` | Message group name |
| `-s, --sound` | Ringtone (alarm, bell, etc.) |
| `-c, --call` | Ring for 30 seconds |
| `-l, --level` | Level: active, timeSensitive, passive |
| `-i, --icon` | Custom icon URL |
| `-b, --badge` | Badge number |
| `--copy` | Content to copy on tap |
| `--auto-copy` | Auto copy on receive |
| `--archive` | Save to history |
| `--redirect` | URL to open on tap |

### WeChat Push

Use `scripts/wechat.sh` for WeChat notifications via Server酱:

```bash
# View help
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/wechat.sh" -h

# Simple push
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/wechat.sh" -t "TOKEN" -x "Task completed"

# With description
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/wechat.sh" -t "TOKEN" -x "Claude Code" -d "Code review done"

# Detailed notification
"${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/wechat.sh" -t "TOKEN" -x "Build completed" -d "Project build successful, took 5 minutes"
```

### WeChat Parameters

| Parameter | Description |
|-----------|-------------|
| `-t, --token` | Server酱 Token (required), get from https://xtuis.cn/ |
| `-x, --text` | Notification title (required) |
| `-d, --desp` | Notification content/description (optional) |

## Recommended Usage Scenarios

Send notifications proactively in these scenarios:

1. **Long task completion** - Build, test, deploy finished
2. **User confirmation needed** - Use `-c` for urgent
3. **Important milestones** - Code review done, PR created
4. **Error alerts** - Build failed, tests not passing

## Operation Steps

### Configure Bark

**IMPORTANT: Always check existing configuration first**

1. **Check if configuration already exists:**
   - Use Read tool to check `.claude/claude-notification.local.md`
   - If file exists and contains `bark_url`:
     - Display current configuration to user
     - Ask if they want to modify it (use AskUserQuestion)
     - If no, skip to step 4 to check CLAUDE.md
     - If yes, continue to step 2
   - If file doesn't exist or bark_url is empty, continue to step 2

2. **Ask user for Bark URL** (only if needed)
   - Ask: "请提供您的 Bark 推送 URL（例如：https://api.day.app/your-key/）"

3. **Create or update configuration file:**
   - Use Write tool to create/update `.claude/claude-notification.local.md`

4. **Check if CLAUDE.md needs notification configuration:**
   - Use Read tool to check if `.claude/CLAUDE.md` exists
   - If exists, check if it already contains "通知功能配置" or "notification"
   - If already configured, inform user and skip to step 6
   - If not configured, continue to step 5

5. **Ask about adding to CLAUDE.md** (only if not already configured):
   - Use AskUserQuestion: "是否要将通知功能添加到项目的 CLAUDE.md 中？这样 AI 就能在完成重要任务时主动发送通知。"
   - Options: "是，添加到 CLAUDE.md" / "否，暂时不需要"
   - If yes: Create or append to `.claude/CLAUDE.md` with the following content.
   - **IMPORTANT**: Replace `{{PLUGIN_PATH}}` with the actual expanded value of `${CLAUDE_PLUGIN_ROOT}` when writing to CLAUDE.md.

```markdown
## 通知功能配置

### Bark 推送配置
* Bark URL: `<user's bark url>`

### 主动通知场景
AI 应该在以下场景主动发送通知：
1. **长时间任务完成** - 构建、测试、部署等耗时任务完成时
2. **需要用户确认** - 重要决策或需要用户介入时（使用 `-c` 参数持续响铃）
3. **重要里程碑** - 代码审查完成、PR 创建成功等
4. **错误警报** - 构建失败、测试未通过等异常情况

### 发送通知方法
使用 Bash 工具调用 bark.sh 脚本：

\```bash
# 基础通知
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.sh" -u "<user's bark url>" -t "Claude Code" -m "任务完成"

# 紧急通知（持续响铃30秒）
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.sh" -u "<user's bark url>" -t "Claude Code" -m "需要确认" -c

# 分组通知
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.sh" -u "<user's bark url>" -t "构建完成" -m "项目构建成功" -g "build"
\```

### 使用原则
* 在用户明确要求通知时发送
* 完成重要任务后主动发送（如代码审查、PR创建、长时间构建等）
* 紧急情况使用 `-c` 参数
* 相关任务使用 `-g` 参数分组
```

6. **Remind user about restart:**
   - Only if configuration was created or modified: **"配置完成后需要重启 Claude Code 才能生效"**

### Configure WeChat

**IMPORTANT: Always check existing configuration first**

1. **Check if configuration already exists:**
   - Use Read tool to check `.claude/claude-notification.local.md`
   - If file exists and contains `wechat_token`:
     - Display current configuration to user
     - Ask if they want to modify it (use AskUserQuestion)
     - If no, skip to step 4 to check CLAUDE.md
     - If yes, continue to step 2
   - If file doesn't exist or wechat_token is empty, continue to step 2

2. **Guide user to get WeChat Token** (only if needed)
   - Tell user: "请按照以下步骤获取微信通知 Token："
   - Step 1: "访问 https://xtuis.cn/"
   - Step 2: "微信扫码关注公众号"
   - Step 3: "获取你的专属 Token 并提供给我"
   - Ask: "请提供您的 Server酱 Token"

3. **Create or update configuration file:**
   - Use Write tool to create/update `.claude/claude-notification.local.md`

4. **Check if CLAUDE.md needs notification configuration:**
   - Use Read tool to check if `.claude/CLAUDE.md` exists
   - If exists, check if it already contains "通知功能配置" or "notification"
   - If already configured, inform user and skip to step 6
   - If not configured, continue to step 5

5. **Ask about adding to CLAUDE.md** (only if not already configured):
   - Use AskUserQuestion: "是否要将微信通知功能添加到项目的 CLAUDE.md 中？这样 AI 就能在完成重要任务时主动发送通知。"
   - Options: "是，添加到 CLAUDE.md" / "否，暂时不需要"
   - If yes: Create or append to `.claude/CLAUDE.md` with the following content.
   - **IMPORTANT**: Replace `{{PLUGIN_PATH}}` with the actual expanded value of `${CLAUDE_PLUGIN_ROOT}` when writing to CLAUDE.md.

```markdown
## 通知功能配置

### 微信推送配置
* WeChat Token: `<user's wechat token>`

### 主动通知场景
AI 应该在以下场景主动发送通知：
1. **长时间任务完成** - 构建、测试、部署等耗时任务完成时
2. **需要用户确认** - 重要决策或需要用户介入时
3. **重要里程碑** - 代码审查完成、PR 创建成功等
4. **错误警报** - 构建失败、测试未通过等异常情况

### 发送通知方法
使用 Bash 工具调用 wechat.sh 脚本：

\```bash
# 基础通知
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/wechat.sh" -t "<user's wechat token>" -x "任务完成"

# 带详细内容
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/wechat.sh" -t "<user's wechat token>" -x "Claude Code" -d "代码审查完成"

# 详细通知
bash "{{PLUGIN_PATH}}/skills/notification-config/scripts/wechat.sh" -t "<user's wechat token>" -x "构建完成" -d "项目构建成功，耗时 5 分钟"
\```

### 使用原则
* 在用户明确要求通知时发送
* 完成重要任务后主动发送（如代码审查、PR创建、长时间构建等）
* 使用 `-x` 参数设置标题，`-d` 参数设置详细内容
```

6. **Remind user about restart:**
   - Only if configuration was created or modified: **"配置完成后需要重启 Claude Code 才能生效"**

### Send Notification Proactively

When user requests notification or after completing important tasks:

1. Read `bark_url` and `wechat_token` from `.claude/claude-notification.local.md`
2. If bark_url exists, use Bash tool to call bark.sh with the exact command format from CLAUDE.md (or use the format shown above if CLAUDE.md doesn't have it)
3. If wechat_token exists, use Bash tool to call wechat.sh with the exact command format from CLAUDE.md (or use the format shown above if CLAUDE.md doesn't have it)
4. Choose appropriate parameters based on scenario (use -c for urgent Bark notifications, use -d for detailed WeChat messages)

## Platform Notes

- **macOS**: Uses osascript for native notifications
- **Linux**: Uses notify-send (requires libnotify)

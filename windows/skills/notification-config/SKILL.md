---
name: notification-config
description: |
  This skill should be used when the user asks to "configure notifications", "set up Bark",
  "configure Bark push", "change notification duration", "make notifications persistent",
  or mentions "Bark", "notification settings", "push notifications".
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
| `bark_only` | boolean | false | Set to true to use only Bark, skip system notifications |
| `always_notify` | boolean | false | Set to true to always notify, even when terminal is in foreground |

### Configuration Template

```markdown
---
bark_url: ""
bark_only: false
always_notify: false
---
```

## Proactive Notification Sending

AI can call notification scripts at appropriate times.

### Available Scripts

Scripts are located in `scripts/` directory of this skill:

- **`scripts/notify.ps1`** - System notification script
- **`scripts/bark.ps1`** - Bark push script with full parameters

### System Notification

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/notify.ps1" -Title "Title" -Message "Content"
```

### Bark Push

Use `scripts/bark.ps1` for rich push notifications:

```powershell
# View help
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.ps1" -Help

# Simple push
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.ps1" -Url "URL" -Message "Task completed"

# With title
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.ps1" -Url "URL" -Title "Claude" -Message "Code review done"

# Urgent (ring for 30s)
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.ps1" -Url "URL" -Message "Urgent!" -Call

# Grouped message
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/notification-config/scripts/bark.ps1" -Url "URL" -Message "Build done" -Group "build"
```

### Bark Parameters

| Parameter | Description |
|-----------|-------------|
| `-Url` | Bark server URL (required) |
| `-Message` | Push content (required) |
| `-Title` | Push title |
| `-Group` | Message group name |
| `-Sound` | Ringtone (alarm, bell, etc.) |
| `-Call` | Ring for 30 seconds |
| `-Level` | Level: active, timeSensitive, passive |
| `-Icon` | Custom icon URL |
| `-Badge` | Badge number |
| `-Copy` | Content to copy on tap |
| `-AutoCopy` | Auto copy on receive |
| `-Archive` | Save to history |
| `-RedirectUrl` | URL to open on tap |

## Recommended Usage Scenarios

Send notifications proactively in these scenarios:

1. **Long task completion** - Build, test, deploy finished
2. **User confirmation needed** - Use `-Call` for urgent
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
2. **需要用户确认** - 重要决策或需要用户介入时（使用 `-Call` 参数持续响铃）
3. **重要里程碑** - 代码审查完成、PR 创建成功等
4. **错误警报** - 构建失败、测试未通过等异常情况

### 发送通知方法
使用 Bash 工具调用 bark.ps1 脚本：

\```powershell
# 基础通知
powershell -NoProfile -ExecutionPolicy Bypass -File "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.ps1" -Url "<user's bark url>" -Title "Claude Code" -Message "任务完成"

# 紧急通知（持续响铃30秒）
powershell -NoProfile -ExecutionPolicy Bypass -File "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.ps1" -Url "<user's bark url>" -Title "Claude Code" -Message "需要确认" -Call

# 分组通知
powershell -NoProfile -ExecutionPolicy Bypass -File "{{PLUGIN_PATH}}/skills/notification-config/scripts/bark.ps1" -Url "<user's bark url>" -Title "构建完成" -Message "项目构建成功" -Group "build"
\```

### 使用原则
* 在用户明确要求通知时发送
* 完成重要任务后主动发送（如代码审查、PR创建、长时间构建等）
* 紧急情况使用 `-Call` 参数
* 相关任务使用 `-Group` 参数分组
```

6. **Remind user about restart:**
   - Only if configuration was created or modified: **"配置完成后需要重启 Claude Code 才能生效"**

### Send Notification Proactively

When user requests notification or after completing important tasks:

1. Read `bark_url` from `.claude/claude-notification.local.md`
2. If bark_url exists, use Bash tool to call bark.ps1 with the exact command format from CLAUDE.md (or use the format shown above if CLAUDE.md doesn't have it)
3. Choose appropriate parameters based on scenario (use -Call for urgent notifications)

#!/bin/bash

# 微信推送 Hook 包装脚本
# 从配置文件读取 Token 并发送微信通知。用于 Hook 自动触发。

TITLE="$1"
MESSAGE="$2"

# 验证必需参数
if [ -z "$TITLE" ]; then
    exit 0  # 静默退出，不报错
fi

# 查找配置文件
CONFIG_PATH="${CLAUDE_PROJECT_DIR}/.claude/claude-notification.local.md"

if [ ! -f "$CONFIG_PATH" ]; then
    exit 0  # 配置文件不存在，静默退出
fi

# 读取配置文件并提取 wechat_token
# 检查是否启用 hook
HOOK_ENABLED=$(grep -E "^wechat_hook_enabled:" "$CONFIG_PATH" | sed -E 's/^wechat_hook_enabled:[[:space:]]*(.*)/\1/')

if [ "$HOOK_ENABLED" = "false" ] || [ "$HOOK_ENABLED" = "no" ] || [ "$HOOK_ENABLED" = "0" ]; then
    exit 0  # Hook 已禁用，静默退出
fi

TOKEN=$(grep -E "^wechat_token:" "$CONFIG_PATH" | sed -E 's/^wechat_token:[[:space:]]*["\']?([^"'\''[:space:]]+)["\']?.*/\1/')

if [ -z "$TOKEN" ]; then
    exit 0  # Token 为空，静默退出
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WECHAT_SCRIPT="${SCRIPT_DIR}/wechat.sh"

# 调用微信推送脚本
if [ -n "$MESSAGE" ]; then
    bash "$WECHAT_SCRIPT" -t "$TOKEN" -x "$TITLE" -d "$MESSAGE" 2>/dev/null
else
    bash "$WECHAT_SCRIPT" -t "$TOKEN" -x "$TITLE" 2>/dev/null
fi

exit 0

#!/bin/bash
# Claude Code Notification Script for macOS/Linux

TITLE="${1:-Claude Code}"
MESSAGE="${2:-通知}"
DIR="${3:-}"

# 检测前台应用是否是终端
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
    TERMINALS="Terminal|iTerm|iTerm2|Alacritty|kitty|Warp|Hyper|Code|Cursor|VSCodium"

    if [[ ! "$FRONT_APP" =~ ^($TERMINALS)$ ]]; then
        if [ -n "$DIR" ]; then
            SHORT_DIR=$(echo "$DIR" | rev | cut -d'/' -f1-2 | rev)
            MESSAGE="$MESSAGE - $SHORT_DIR"
        fi
        osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
    fi
else
    # Linux
    if command -v notify-send &> /dev/null; then
        if [ -n "$DIR" ]; then
            SHORT_DIR=$(echo "$DIR" | rev | cut -d'/' -f1-2 | rev)
            MESSAGE="$MESSAGE - $SHORT_DIR"
        fi
        notify-send "$TITLE" "$MESSAGE"
    fi
fi

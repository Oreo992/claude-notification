#!/bin/bash
# Bark 推送通知脚本
# 向 iOS Bark 应用发送推送通知，支持多种推送方式和参数配置

set -euo pipefail

# 默认值
URL=""
MESSAGE=""
TITLE=""
GROUP=""
SOUND=""
CALL=""
LEVEL=""
ICON=""
BADGE=""
COPY=""
AUTO_COPY=""
ARCHIVE=""
REDIRECT_URL=""

# 帮助信息
show_help() {
    cat << 'EOF'
Bark 推送通知脚本

用法:
    bark.sh -u <bark-url> -m <消息> [选项]
    bark.sh --url <bark-url> --message <消息> [选项]

必需参数:
    -u, --url        Bark 服务器地址，格式：https://api.day.app/your-key
    -m, --message    推送内容

可选参数:
    -t, --title      推送标题
    -g, --group      消息分组名称
    -s, --sound      推送铃声（alarm, anticipate, bell, birdsong, bloom 等）
    -c, --call       持续响铃30秒（紧急通知）
    -l, --level      通知级别：active（默认）, timeSensitive（时效性）, passive（静默）
    -i, --icon       自定义图标 URL
    -b, --badge      角标数字
    --copy           点击通知时复制的内容
    --auto-copy      收到通知自动复制
    --archive        保存到历史记录
    --redirect       点击通知跳转的 URL
    -h, --help       显示此帮助信息

示例:
    # 简单推送
    ./bark.sh -u "https://api.day.app/xxx" -m "任务完成"

    # 带标题
    ./bark.sh -u "https://api.day.app/xxx" -t "Claude" -m "代码审查完成"

    # 紧急通知（持续响铃）
    ./bark.sh -u "https://api.day.app/xxx" -m "紧急通知" -c

    # 分组消息
    ./bark.sh -u "https://api.day.app/xxx" -m "任务完成" -g "claude-code"

    # 时效性通知
    ./bark.sh -u "https://api.day.app/xxx" -m "需要确认" -l timeSensitive

    # 完整示例
    ./bark.sh -u "https://api.day.app/xxx" -t "Claude Code" -m "构建完成" -g "build" -s bell
EOF
}

# URL 编码函数
urlencode() {
    local string="$1"
    # 优先使用 jq，否则使用 python
    if command -v jq &> /dev/null; then
        printf '%s' "$string" | jq -sRr @uri
    elif command -v python3 &> /dev/null; then
        python3 -c "import urllib.parse; print(urllib.parse.quote('$string', safe=''))"
    elif command -v python &> /dev/null; then
        python -c "import urllib; print urllib.quote('$string', safe='')"
    else
        # 简单的 URL 编码（基本字符）
        echo "$string" | sed 's/ /%20/g; s/!/%21/g; s/"/%22/g; s/#/%23/g; s/\$/%24/g; s/&/%26/g; s/'"'"'/%27/g; s/(/%28/g; s/)/%29/g; s/+/%2B/g; s/,/%2C/g'
    fi
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -m|--message)
            MESSAGE="$2"
            shift 2
            ;;
        -t|--title)
            TITLE="$2"
            shift 2
            ;;
        -g|--group)
            GROUP="$2"
            shift 2
            ;;
        -s|--sound)
            SOUND="$2"
            shift 2
            ;;
        -c|--call)
            CALL="1"
            shift
            ;;
        -l|--level)
            LEVEL="$2"
            shift 2
            ;;
        -i|--icon)
            ICON="$2"
            shift 2
            ;;
        -b|--badge)
            BADGE="$2"
            shift 2
            ;;
        --copy)
            COPY="$2"
            shift 2
            ;;
        --auto-copy)
            AUTO_COPY="1"
            shift
            ;;
        --archive)
            ARCHIVE="1"
            shift
            ;;
        --redirect)
            REDIRECT_URL="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "未知参数: $1" >&2
            echo "使用 -h 或 --help 查看帮助" >&2
            exit 1
            ;;
    esac
done

# 验证必需参数
if [[ -z "$URL" ]]; then
    echo "错误: 缺少 -u/--url 参数" >&2
    echo "使用 -h 或 --help 查看帮助" >&2
    exit 1
fi

if [[ -z "$MESSAGE" ]]; then
    echo "错误: 缺少 -m/--message 参数" >&2
    echo "使用 -h 或 --help 查看帮助" >&2
    exit 1
fi

# 构建 URL
ENCODED_MESSAGE=$(urlencode "$MESSAGE")

if [[ -n "$TITLE" ]]; then
    ENCODED_TITLE=$(urlencode "$TITLE")
    FULL_URL="$URL/$ENCODED_TITLE/$ENCODED_MESSAGE"
else
    FULL_URL="$URL/$ENCODED_MESSAGE"
fi

# 构建查询参数
QUERY_PARAMS=""

add_param() {
    local key="$1"
    local value="$2"
    if [[ -z "$QUERY_PARAMS" ]]; then
        QUERY_PARAMS="?${key}=${value}"
    else
        QUERY_PARAMS="${QUERY_PARAMS}&${key}=${value}"
    fi
}

if [[ -n "$GROUP" ]]; then
    add_param "group" "$(urlencode "$GROUP")"
fi

if [[ -n "$SOUND" ]]; then
    add_param "sound" "$(urlencode "$SOUND")"
fi

if [[ -n "$CALL" ]]; then
    add_param "call" "1"
fi

if [[ -n "$LEVEL" ]]; then
    add_param "level" "$LEVEL"
fi

if [[ -n "$ICON" ]]; then
    add_param "icon" "$(urlencode "$ICON")"
fi

if [[ -n "$BADGE" ]]; then
    add_param "badge" "$BADGE"
fi

if [[ -n "$COPY" ]]; then
    add_param "copy" "$(urlencode "$COPY")"
fi

if [[ -n "$AUTO_COPY" ]]; then
    add_param "autoCopy" "1"
fi

if [[ -n "$ARCHIVE" ]]; then
    add_param "isArchive" "1"
fi

if [[ -n "$REDIRECT_URL" ]]; then
    add_param "url" "$(urlencode "$REDIRECT_URL")"
fi

# 拼接完整 URL
FULL_URL="${FULL_URL}${QUERY_PARAMS}"

# 发送请求
if curl -s -m 10 "$FULL_URL" > /dev/null 2>&1; then
    echo "推送成功"
    exit 0
else
    echo "推送失败" >&2
    exit 1
fi

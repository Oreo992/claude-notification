#!/bin/bash

# 微信推送通知脚本
# 通过 https://xtuis.cn/ 向微信发送推送通知

show_help() {
    cat << EOF
微信推送通知脚本

用法:
    wechat.sh -t <token> -x <标题> [-d <内容>]

必需参数:
    -t, --token     Token，从 https://xtuis.cn/ 获取
    -x, --text      通知标题

可选参数:
    -d, --desp      通知内容/描述
    -h, --help      显示此帮助信息

获取 Token:
    1. 访问 https://xtuis.cn/
    2. 微信扫码关注公众号
    3. 获取你的专属 Token

示例:
    # 简单推送
    ./wechat.sh -t "your-token" -x "任务完成"

    # 带内容
    ./wechat.sh -t "your-token" -x "Claude Code" -d "代码审查完成"

    # 详细通知
    ./wechat.sh -t "your-token" -x "构建完成" -d "项目构建成功，耗时 5 分钟"
EOF
    exit 0
}

# 参数解析
TOKEN=""
TEXT=""
DESP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--token)
            TOKEN="$2"
            shift 2
            ;;
        -x|--text)
            TEXT="$2"
            shift 2
            ;;
        -d|--desp)
            DESP="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "错误: 未知参数 $1"
            show_help
            ;;
    esac
done

# 验证必需参数
if [ -z "$TOKEN" ]; then
    echo "错误: 缺少 -t/--token 参数" >&2
    exit 1
fi

if [ -z "$TEXT" ]; then
    echo "错误: 缺少 -x/--text 参数" >&2
    exit 1
fi

# URL 编码函数
urlencode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * ) printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# 构建 URL
BASE_URL="https://wx.xtuis.cn/${TOKEN}.send"
ENCODED_TEXT=$(urlencode "$TEXT")

# 构建查询参数
QUERY="text=${ENCODED_TEXT}"

if [ -n "$DESP" ]; then
    ENCODED_DESP=$(urlencode "$DESP")
    QUERY="${QUERY}&desp=${ENCODED_DESP}"
fi

FULL_URL="${BASE_URL}?${QUERY}"

# 发送请求
if command -v curl &> /dev/null; then
    response=$(curl -s -w "\n%{http_code}" -X GET "$FULL_URL" --max-time 10)
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" = "200" ]; then
        echo "微信推送成功"
        exit 0
    else
        echo "微信推送失败: HTTP $http_code" >&2
        exit 1
    fi
else
    echo "错误: 未找到 curl 命令" >&2
    exit 1
fi

<#
.SYNOPSIS
    微信推送 Hook 包装脚本

.DESCRIPTION
    从配置文件读取 Token 并发送微信通知。用于 Hook 自动触发。

.PARAMETER Title
    通知标题（必需）

.PARAMETER Message
    通知内容（可选）
#>

param(
    [Parameter(Position=0)]
    [string]$Title,

    [Parameter(Position=1)]
    [string]$Message
)

# 验证必需参数
if (-not $Title) {
    exit 0  # 静默退出，不报错
}

# 查找配置文件
$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) {
    $projectDir = Get-Location
}
$configPath = Join-Path $projectDir ".claude\claude-notification.local.md"

if (-not (Test-Path $configPath)) {
    exit 0  # 配置文件不存在，静默退出
}

# 读取配置文件
try {
    $content = Get-Content $configPath -Raw -Encoding UTF8

    # 检查是否启用 hook
    $hookEnabled = $true
    if ($content -match 'wechat_hook_enabled:\s*(false|no|0)') {
        exit 0  # Hook 已禁用，静默退出
    }

    # 提取 wechat_token
    if ($content -match 'wechat_token:\s*["'']?([^"''\r\n]+)["'']?') {
        $token = $matches[1].Trim()

        if ([string]::IsNullOrWhiteSpace($token)) {
            exit 0  # Token 为空，静默退出
        }

        # 调用微信推送脚本
        $scriptPath = Join-Path $PSScriptRoot "wechat.ps1"

        if ($Message) {
            & $scriptPath -Token $token -Text $Title -Desp $Message
        } else {
            & $scriptPath -Token $token -Text $Title
        }
    }
} catch {
    # 发生错误，静默退出
    exit 0
}

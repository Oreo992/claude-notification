<#
.SYNOPSIS
    微信推送通知脚本

.DESCRIPTION
    通过（xtuis.cn）向微信发送推送通知。

.PARAMETER Token
    Token（必需），从 https://xtuis.cn/ 获取

.PARAMETER Text
    通知标题（必需）

.PARAMETER Desp
    通知内容/描述（可选）

.PARAMETER Help
    显示帮助信息

.EXAMPLE
    .\wechat.ps1 -Token "your-token" -Text "任务完成"

.EXAMPLE
    .\wechat.ps1 -Token "your-token" -Text "Claude Code" -Desp "代码审查完成"

.EXAMPLE
    .\wechat.ps1 -Token "your-token" -Text "构建完成" -Desp "项目构建成功，耗时 5 分钟"
#>

param(
    [Parameter(Position=0)]
    [string]$Token,

    [Parameter(Position=1)]
    [string]$Text,

    [Parameter(Position=2)]
    [string]$Desp,

    [Alias("h")]
    [switch]$Help
)

# 显示帮助
if ($Help -or (-not $Token -and -not $Text)) {
    Write-Host @"
微信推送通知脚本

用法:
    wechat.ps1 -Token <token> -Text <标题> [-Desp <内容>]

必需参数:
    -Token      Token，从 https://xtuis.cn/ 获取
    -Text       通知标题

可选参数:
    -Desp       通知内容/描述
    -Help, -h   显示此帮助信息

获取 Token:
    1. 访问 https://xtuis.cn/
    2. 微信扫码关注公众号
    3. 获取你的专属 Token

示例:
    # 简单推送
    .\wechat.ps1 -Token "your-token" -Text "任务完成"

    # 带内容
    .\wechat.ps1 -Token "your-token" -Text "Claude Code" -Desp "代码审查完成"

    # 详细通知
    .\wechat.ps1 -Token "your-token" -Text "构建完成" -Desp "项目构建成功，耗时 5 分钟"
"@
    exit 0
}

# 验证必需参数
if (-not $Token) {
    Write-Error "错误: 缺少 -Token 参数"
    exit 1
}

if (-not $Text) {
    Write-Error "错误: 缺少 -Text 参数"
    exit 1
}

# 构建 URL
$baseUrl = "https://wx.xtuis.cn/$Token.send"

# 构建查询参数
$queryParams = @()
$queryParams += "text=$([System.Uri]::EscapeDataString($Text))"

if ($Desp) {
    $queryParams += "desp=$([System.Uri]::EscapeDataString($Desp))"
}

# 拼接完整 URL
$fullUrl = $baseUrl + "?" + ($queryParams -join "&")

# 发送请求
try {
    $response = Invoke-RestMethod -Uri $fullUrl -Method Get -TimeoutSec 10
    Write-Host "微信推送成功"
    exit 0
} catch {
    Write-Error "微信推送失败: $_"
    exit 1
}

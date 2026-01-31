<#
.SYNOPSIS
    Bark 推送通知脚本

.DESCRIPTION
    向 iOS Bark 应用发送推送通知，支持多种推送方式和参数配置。

.PARAMETER Url
    Bark 服务器地址（必需），格式：https://api.day.app/your-key

.PARAMETER Message
    推送内容（必需）

.PARAMETER Title
    推送标题（可选）

.PARAMETER Group
    消息分组名称（可选）

.PARAMETER Sound
    推送铃声（可选），如：alarm, anticipate, bell, birdsong 等

.PARAMETER Call
    持续响铃30秒（可选开关）

.PARAMETER Level
    通知级别（可选）：active（默认）, timeSensitive（时效性）, passive（静默）

.PARAMETER Icon
    自定义图标 URL（可选）

.PARAMETER Badge
    角标数字（可选）

.PARAMETER Copy
    点击通知时复制的内容（可选）

.PARAMETER AutoCopy
    收到通知自动复制（可选开关）

.PARAMETER Archive
    是否保存到历史记录（可选开关）

.PARAMETER RedirectUrl
    点击通知跳转的 URL（可选）

.PARAMETER Help
    显示帮助信息

.EXAMPLE
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "任务完成"

.EXAMPLE
    .\bark.ps1 -Url "https://api.day.app/xxx" -Title "Claude" -Message "代码审查完成"

.EXAMPLE
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "紧急通知" -Call

.EXAMPLE
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "任务完成" -Group "claude-code"
#>

param(
    [Parameter(Position=0)]
    [string]$Url,

    [Parameter(Position=1)]
    [string]$Message,

    [string]$Title,
    [string]$Group,
    [string]$Sound,
    [switch]$Call,
    [ValidateSet("active", "timeSensitive", "passive")]
    [string]$Level,
    [string]$Icon,
    [int]$Badge,
    [string]$Copy,
    [switch]$AutoCopy,
    [switch]$Archive,
    [string]$RedirectUrl,
    [Alias("h")]
    [switch]$Help
)

# 显示帮助
if ($Help -or (-not $Url -and -not $Message)) {
    Write-Host @"
Bark 推送通知脚本

用法:
    bark.ps1 -Url <bark-url> -Message <消息> [选项]

必需参数:
    -Url        Bark 服务器地址，格式：https://api.day.app/your-key
    -Message    推送内容

可选参数:
    -Title      推送标题
    -Group      消息分组名称
    -Sound      推送铃声（alarm, anticipate, bell, birdsong, bloom 等）
    -Call       持续响铃30秒（紧急通知）
    -Level      通知级别：active（默认）, timeSensitive（时效性）, passive（静默）
    -Icon       自定义图标 URL
    -Badge      角标数字
    -Copy       点击通知时复制的内容
    -AutoCopy   收到通知自动复制
    -Archive    保存到历史记录
    -RedirectUrl 点击通知跳转的 URL
    -Help, -h   显示此帮助信息

示例:
    # 简单推送
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "任务完成"

    # 带标题
    .\bark.ps1 -Url "https://api.day.app/xxx" -Title "Claude" -Message "代码审查完成"

    # 紧急通知（持续响铃）
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "紧急通知" -Call

    # 分组消息
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "任务完成" -Group "claude-code"

    # 时效性通知
    .\bark.ps1 -Url "https://api.day.app/xxx" -Message "需要确认" -Level timeSensitive
"@
    exit 0
}

# 验证必需参数
if (-not $Url) {
    Write-Error "错误: 缺少 -Url 参数"
    exit 1
}

if (-not $Message) {
    Write-Error "错误: 缺少 -Message 参数"
    exit 1
}

# 构建 URL
$encodedMessage = [System.Uri]::EscapeDataString($Message)

if ($Title) {
    $encodedTitle = [System.Uri]::EscapeDataString($Title)
    $fullUrl = "$Url/$encodedTitle/$encodedMessage"
} else {
    $fullUrl = "$Url/$encodedMessage"
}

# 构建查询参数
$queryParams = @()

if ($Group) {
    $queryParams += "group=$([System.Uri]::EscapeDataString($Group))"
}

if ($Sound) {
    $queryParams += "sound=$([System.Uri]::EscapeDataString($Sound))"
}

if ($Call) {
    $queryParams += "call=1"
}

if ($Level) {
    $queryParams += "level=$Level"
}

if ($Icon) {
    $queryParams += "icon=$([System.Uri]::EscapeDataString($Icon))"
}

if ($Badge -gt 0) {
    $queryParams += "badge=$Badge"
}

if ($Copy) {
    $queryParams += "copy=$([System.Uri]::EscapeDataString($Copy))"
}

if ($AutoCopy) {
    $queryParams += "autoCopy=1"
}

if ($Archive) {
    $queryParams += "isArchive=1"
}

if ($RedirectUrl) {
    $queryParams += "url=$([System.Uri]::EscapeDataString($RedirectUrl))"
}

# 拼接查询参数
if ($queryParams.Count -gt 0) {
    $fullUrl += "?" + ($queryParams -join "&")
}

# 发送请求
try {
    $response = Invoke-RestMethod -Uri $fullUrl -Method Get -TimeoutSec 10
    Write-Host "推送成功"
    exit 0
} catch {
    Write-Error "推送失败: $_"
    exit 1
}

param([string]$Title = "Claude Code", [string]$Message = "通知", [string]$Dir = "")

# 如果 Dir 为空或未展开，尝试从环境变量获取
if (-not $Dir -or $Dir -eq '${CLAUDE_PROJECT_DIR}' -or $Dir -eq '$CLAUDE_PROJECT_DIR') {
    $Dir = $env:CLAUDE_PROJECT_DIR
    if (-not $Dir) {
        # 如果环境变量也没有，使用当前工作目录
        $Dir = Get-Location
    }
}

# 读取配置文件
$configFile = Join-Path $Dir ".claude/claude-notification.local.md"
$barkUrl = ""
$barkOnly = $false
$timeout = 3000

if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    # 解析 YAML frontmatter
    if ($content -match '(?s)^---\r?\n(.+?)\r?\n---') {
        $frontmatter = $Matches[1]
        # 提取 bark_url
        if ($frontmatter -match 'bark_url:\s*[''"]?([^''"}\r\n]+)[''"]?') {
            $barkUrl = $Matches[1].Trim()
        }
        # 提取 bark_only
        if ($frontmatter -match 'bark_only:\s*(true|false)') {
            $barkOnly = $Matches[1] -eq 'true'
        }
        # 提取 timeout
        if ($frontmatter -match 'timeout:\s*(\d+)') {
            $timeout = [int]$Matches[1]
        }
    }
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
}
"@

$foregroundWindow = [Win32]::GetForegroundWindow()
$foregroundPid = 0
[Win32]::GetWindowThreadProcessId($foregroundWindow, [ref]$foregroundPid) | Out-Null

# 向上遍历进程树，找到有窗口的祖先进程（终端窗口）
$currentPid = $PID
$myTerminalPid = $null
for ($i = 0; $i -lt 20; $i++) {
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$currentPid" -ErrorAction SilentlyContinue
    if (-not $proc -or -not $proc.ParentProcessId) { break }
    $parentProc = Get-Process -Id $proc.ParentProcessId -ErrorAction SilentlyContinue
    if ($parentProc -and $parentProc.MainWindowHandle -ne [IntPtr]::Zero) {
        $myTerminalPid = $parentProc.Id
        break
    }
    $currentPid = $proc.ParentProcessId
}

# 只有当前台窗口不是我们的终端窗口时才发通知
if ($foregroundPid -ne $myTerminalPid) {
    if ($Dir) {
        $parts = $Dir -split '[/\\]' | Where-Object { $_ }
        $shortDir = ($parts | Select-Object -Last 2) -join '/'
        $Message = "$Message - $shortDir"
    }

    # 发送 Bark 通知
    if ($barkUrl) {
        try {
            $encodedTitle = [System.Uri]::EscapeDataString($Title)
            $encodedMessage = [System.Uri]::EscapeDataString($Message)
            $barkFullUrl = "$barkUrl/$encodedTitle/$encodedMessage"
            Invoke-RestMethod -Uri $barkFullUrl -Method Get -TimeoutSec 5 | Out-Null
        } catch {
            # Bark 发送失败，静默忽略
        }
    }

    # 发送系统通知（除非 bark_only 为 true）
    if (-not $barkOnly) {
        Add-Type -AssemblyName System.Windows.Forms
        $notify = New-Object System.Windows.Forms.NotifyIcon
        $notify.Icon = [System.Drawing.SystemIcons]::Information
        $notify.BalloonTipTitle = $Title
        $notify.BalloonTipText = $Message
        $notify.Visible = $true
        $notify.ShowBalloonTip($timeout)
        $notify.Dispose()
    }
}

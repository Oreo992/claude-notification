param([string]$Title = "Claude Code", [string]$Message = "通知", [string]$Dir = "")

# 如果 Dir 为空或未展开，尝试从环境变量获取
if (-not $Dir -or $Dir -eq '${CLAUDE_PROJECT_DIR}' -or $Dir -eq '$CLAUDE_PROJECT_DIR') {
    $Dir = $env:CLAUDE_PROJECT_DIR
    if (-not $Dir) {
        $Dir = Get-Location
    }
}

# 读取配置文件
$configFile = Join-Path $Dir ".claude/claude-notification.local.md"
$barkUrl = ""
$barkOnly = $false
$alwaysNotify = $false

if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    if ($content -match '(?s)^---\r?\n(.+?)\r?\n---') {
        $frontmatter = $Matches[1]
        if ($frontmatter -match 'bark_url:\s*[''"]?([^''"}\r\n]+)[''"]?') {
            $barkUrl = $Matches[1].Trim()
        }
        if ($frontmatter -match 'bark_only:\s*(true|false)') {
            $barkOnly = $Matches[1] -eq 'true'
        }
        if ($frontmatter -match 'always_notify:\s*(true|false)') {
            $alwaysNotify = $Matches[1] -eq 'true'
        }
    }
}

# 前台检测
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
}
"@
}

$foregroundWindow = [Win32]::GetForegroundWindow()
$foregroundPid = 0
[Win32]::GetWindowThreadProcessId($foregroundWindow, [ref]$foregroundPid) | Out-Null

$currentPid = $PID
$myTerminalPid = $null
$terminalName = $null
for ($i = 0; $i -lt 20; $i++) {
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$currentPid" -ErrorAction SilentlyContinue
    if (-not $proc -or -not $proc.ParentProcessId) { break }
    $parentProc = Get-Process -Id $proc.ParentProcessId -ErrorAction SilentlyContinue
    if ($parentProc -and $parentProc.MainWindowHandle -ne [IntPtr]::Zero) {
        $myTerminalPid = $parentProc.Id
        # 获取终端名称（优先使用主窗口标题，否则使用进程名）
        if ($parentProc.MainWindowTitle) {
            $terminalName = $parentProc.MainWindowTitle
        } else {
            $terminalName = $parentProc.ProcessName
        }
        break
    }
    $currentPid = $proc.ParentProcessId
}

$shouldNotify = $alwaysNotify -or ($foregroundPid -ne $myTerminalPid)

if ($shouldNotify) {
    if ($Dir) {
        $parts = $Dir -split '[/\\]' | Where-Object { $_ }
        $shortDir = ($parts | Select-Object -Last 2) -join '/'
        $Message = "$Message - $shortDir"
    }

    # 添加终端名称
    if ($terminalName) {
        $Message = "$Message [$terminalName]"
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

    # 发送 Windows Toast 通知（除非 bark_only 为 true）
    if (-not $barkOnly) {
        try {
            # 加载 Windows Runtime 组件
            [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
            [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

            # 应用标识符（使用 PowerShell 的 AppUserModelId）
            $AppId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

            # 创建 Toast XML 模板
            $ToastXml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$([System.Security.SecurityElement]::Escape($Title))</text>
            <text>$([System.Security.SecurityElement]::Escape($Message))</text>
        </binding>
    </visual>
    <audio silent="true"/>
</toast>
"@

            # 加载 XML
            $XmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
            $XmlDoc.LoadXml($ToastXml)

            # 创建并显示通知
            $Toast = [Windows.UI.Notifications.ToastNotification]::new($XmlDoc)
            $Toast.Tag = "ClaudeCode"
            $Toast.Group = "ClaudeCode"

            $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId)
            $Notifier.Show($Toast)
        } catch {
            # Toast 通知失败，回退到 BalloonTip
            try {
                Add-Type -AssemblyName System.Windows.Forms
                $notify = New-Object System.Windows.Forms.NotifyIcon
                $notify.Icon = [System.Drawing.SystemIcons]::Information
                $notify.BalloonTipTitle = $Title
                $notify.BalloonTipText = $Message
                $notify.Visible = $true
                $notify.ShowBalloonTip(5000)
                # 不使用 Start-Sleep，让通知异步显示
                $notify.Dispose()
            } catch {
                # 完全失败，静默忽略
            }
        }
    }
}

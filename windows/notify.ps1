param([string]$Title = "Claude Code", [string]$Message = "通知", [string]$Dir = "")

# 如果 Dir 为空或未展开，尝试从环境变量获取
if (-not $Dir -or $Dir -eq '${CLAUDE_PROJECT_DIR}' -or $Dir -eq '$CLAUDE_PROJECT_DIR') {
    $Dir = $env:CLAUDE_PROJECT_DIR
    if (-not $Dir) {
        # 如果环境变量也没有，使用当前工作目录
        $Dir = Get-Location
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

    Add-Type -AssemblyName System.Windows.Forms
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.BalloonTipTitle = $Title
    $notify.BalloonTipText = $Message
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
    $notify.Dispose()
}

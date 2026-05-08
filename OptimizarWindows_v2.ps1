# ================================================================
#   KaraClan_OptimizarWindows_v2.ps1
#   Kara Clan — Free Distribution
#   Run as Administrator
#   Vol.2 — Advanced (Gaming + GPU + System)
# ================================================================

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan — Optimizer v2 (Advanced)"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

# ── Admin Check ─────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] You must run this script as Administrator." -ForegroundColor Red
    Write-Host "  Right-click the file and select 'Run as Administrator'." -ForegroundColor Yellow
    pause
    exit
}

# ── Header ──────────────────────────────────────────────────────
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN — OPTIMIZADOR v2" -ForegroundColor Cyan
Write-Host "   Advanced Gaming + System — Windows 10/11" -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$tweaks = 0

# ═══════════════ NETWORK ═══════════════
Write-Host "  [ NETWORK ]" -ForegroundColor Cyan
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray

# 1. Nagle OFF
Write-Host "  [1] TcpAckFrequency + TCPNoDelay (Nagle OFF)..." -ForegroundColor Yellow
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $ifaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
}
Write-Host "      [OK] Applied to $($ifaces.Count) interfaces" -ForegroundColor Green
$tweaks++

# 2. Cloudflare DNS
Write-Host "  [2] Cloudflare DNS (1.1.1.1 / 1.0.0.1)..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1")
}
Write-Host "      [OK] Configured on $($adapters.Count) adapters" -ForegroundColor Green
$tweaks++

# 3. Flush DNS
Write-Host "  [3] Flush DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "      [OK] Flushed" -ForegroundColor Green
$tweaks++

# 4. Delivery Optimization OFF
Write-Host "  [4] Delivery Optimization OFF..." -ForegroundColor Yellow
$doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (-not (Test-Path $doPath)) { New-Item -Path $doPath -Force | Out-Null }
Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 5. Background Bandwidth Limit
Write-Host "  [5] Background bandwidth limit (1 Mbps)..." -ForegroundColor Yellow
$doPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"
if (-not (Test-Path $doPath2)) { New-Item -Path $doPath2 -Force | Out-Null }
Set-ItemProperty -Path $doPath2 -Name "DownloadRateBackgroundBps" -Value 125000 -Type DWord -Force
Write-Host "      [OK] 1 Mbps" -ForegroundColor Green
$tweaks++

# 6. QoS DSCP 46 (Gaming priority)
Write-Host "  [6] QoS DSCP 46 (Gaming packet priority)..." -ForegroundColor Yellow
$qos = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\Gaming"
if (-not (Test-Path $qos)) { New-Item -Path $qos -Force | Out-Null }
Set-ItemProperty -Path $qos -Name "Version" -Value "1.0" -Force
Set-ItemProperty -Path $qos -Name "Protocol" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "Application Name" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "Local Port" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "Local IP" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "Remote Port" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "Remote IP" -Value "*" -Force
Set-ItemProperty -Path $qos -Name "DSCP Value" -Value "46" -Force
Set-ItemProperty -Path $qos -Name "Throttle Rate" -Value "-1" -Force
Write-Host "      [OK] DSCP 46 activated" -ForegroundColor Green
$tweaks++

# 7. QoS Reserve 0%
Write-Host "  [7] QoS Reserve 0%..." -ForegroundColor Yellow
$ql = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
if (-not (Test-Path $ql)) { New-Item -Path $ql -Force | Out-Null }
Set-ItemProperty -Path $ql -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
Write-Host "      [OK] 0%" -ForegroundColor Green
$tweaks++

# 8. NetworkThrottlingIndex OFF
Write-Host "  [8] NetworkThrottlingIndex OFF..." -ForegroundColor Yellow
$mm = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $mm -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path $mm -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# ═══════════════ SYSTEM ═══════════════
Write-Host ""
Write-Host "  [ SYSTEM ]" -ForegroundColor Magenta
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray

# 9. High Performance Power Plan
Write-Host "  [9] High Performance Power Plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
Write-Host "      [OK] ON" -ForegroundColor Green
$tweaks++

# 10. Hibernate OFF
Write-Host "  [10] Hibernate OFF..." -ForegroundColor Yellow
powercfg -h off 2>$null
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 11. GPU Priority 8 (Gaming)
Write-Host "  [11] GPU Priority 8 (Gaming)..." -ForegroundColor Yellow
$gp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Force
Write-Host "      [OK] GPU 8 | CPU 6" -ForegroundColor Green
$tweaks++

# 12. Telemetry OFF
Write-Host "  [12] Telemetry OFF..." -ForegroundColor Yellow
$tel = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $tel)) { New-Item -Path $tel -Force | Out-Null }
Set-ItemProperty -Path $tel -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 13. Background Apps OFF
Write-Host "  [13] Background Apps OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 14. Xbox Game Bar + DVR OFF
Write-Host "  [14] Xbox Game Bar + DVR OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
$gd = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (-not (Test-Path $gd)) { New-Item -Path $gd -Force | Out-Null }
Set-ItemProperty -Path $gd -Name "AllowGameDVR" -Value 0 -Type DWord -Force
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 15. Game Mode ON
Write-Host "  [15] Game Mode ON..." -ForegroundColor Yellow
$gm = "HKCU:\SOFTWARE\Microsoft\GameBar"
if (-not (Test-Path $gm)) { New-Item -Path $gm -Force | Out-Null }
Set-ItemProperty -Path $gm -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force
Write-Host "      [OK] ON" -ForegroundColor Green
$tweaks++

# 16. SysMain OFF
Write-Host "  [16] SysMain OFF..." -ForegroundColor Yellow
Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue
Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Host "      [OK] OFF" -ForegroundColor Green
$tweaks++

# 17. Windows Search Manual
Write-Host "  [17] Windows Search (Manual)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Value 3 -Type DWord -Force
Write-Host "      [OK] Manual" -ForegroundColor Green
$tweaks++

# ── Footer ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN — COMPLETED — $tweaks tweaks applied" -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your PC for changes to take effect." -ForegroundColor Yellow
Write-Host ""
pause

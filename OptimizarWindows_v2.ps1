$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan - Optimizer v2"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Run this script as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN - OPTIMIZADOR v2" -ForegroundColor Cyan
Write-Host "   Advanced Gaming + System" -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$c = 0

Write-Host "[$((++$c))/17] Nagle OFF..." -ForegroundColor Yellow
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $ifaces) { Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force; Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force }
Write-Host "  [OK] Applied" -ForegroundColor Green

Write-Host "[$((++$c))/17] Cloudflare DNS..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) { Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1") }
Write-Host "  [OK] DNS configured" -ForegroundColor Green

Write-Host "[$((++$c))/17] Flush DNS..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  [OK] Flushed" -ForegroundColor Green

Write-Host "[$((++$c))/17] Delivery Optimization OFF..." -ForegroundColor Yellow
$do = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (-not (Test-Path $do)) { New-Item -Path $do -Force | Out-Null }
Set-ItemProperty -Path $do -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] Bandwidth limit 1 Mbps..." -ForegroundColor Yellow
$do2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"
if (-not (Test-Path $do2)) { New-Item -Path $do2 -Force | Out-Null }
Set-ItemProperty -Path $do2 -Name "DownloadRateBackgroundBps" -Value 125000 -Type DWord -Force
Write-Host "  [OK] 1 Mbps" -ForegroundColor Green

Write-Host "[$((++$c))/17] QoS DSCP 46..." -ForegroundColor Yellow
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
Write-Host "  [OK] DSCP 46" -ForegroundColor Green

Write-Host "[$((++$c))/17] QoS Reserve 0%..." -ForegroundColor Yellow
$ql = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
if (-not (Test-Path $ql)) { New-Item -Path $ql -Force | Out-Null }
Set-ItemProperty -Path $ql -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
Write-Host "  [OK] 0%" -ForegroundColor Green

Write-Host "[$((++$c))/17] NetworkThrottlingIndex OFF..." -ForegroundColor Yellow
$mm = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $mm -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path $mm -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] High Performance Power Plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
Write-Host "  [OK] ON" -ForegroundColor Green

Write-Host "[$((++$c))/17] Hibernate OFF..." -ForegroundColor Yellow
powercfg -h off 2>$null
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] GPU Priority 8..." -ForegroundColor Yellow
$gp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (-not (Test-Path $gp)) { New-Item -Path $gp -Force | Out-Null }
Set-ItemProperty -Path $gp -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gp -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gp -Name "Scheduling Category" -Value "High" -Force
Write-Host "  [OK] GPU 8 | CPU 6" -ForegroundColor Green

Write-Host "[$((++$c))/17] Telemetry OFF..." -ForegroundColor Yellow
$tel = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $tel)) { New-Item -Path $tel -Force | Out-Null }
Set-ItemProperty -Path $tel -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] Background Apps OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] Game Bar OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
$gd = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (-not (Test-Path $gd)) { New-Item -Path $gd -Force | Out-Null }
Set-ItemProperty -Path $gd -Name "AllowGameDVR" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] Game Mode ON..." -ForegroundColor Yellow
$gm = "HKCU:\SOFTWARE\Microsoft\GameBar"
if (-not (Test-Path $gm)) { New-Item -Path $gm -Force | Out-Null }
Set-ItemProperty -Path $gm -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force
Write-Host "  [OK] ON" -ForegroundColor Green

Write-Host "[$((++$c))/17] SysMain OFF..." -ForegroundColor Yellow
Stop-Service "SysMain" -Force -ErrorAction SilentlyContinue
Set-Service "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/17] Windows Search Manual..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Value 3 -Type DWord -Force
Write-Host "  [OK] Manual" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN v2 - COMPLETED - 17 tweaks" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your PC." -ForegroundColor Yellow
pause

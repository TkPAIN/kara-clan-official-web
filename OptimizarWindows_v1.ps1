$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan - Optimizer v1"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Run this script as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN - OPTIMIZADOR v1" -ForegroundColor Cyan
Write-Host "   Network & Performance - Windows 10/11" -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/8] Nagle OFF..." -ForegroundColor Yellow
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($i in $ifaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Applied" -ForegroundColor Green

Write-Host "[2/8] High Performance Power Plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
Write-Host "  [OK] Activated" -ForegroundColor Green

Write-Host "[3/8] Cloudflare DNS..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
}
Write-Host "  [OK] DNS configured" -ForegroundColor Green

Write-Host "[4/8] Flush DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  [OK] Flushed" -ForegroundColor Green

Write-Host "[5/8] Delivery Optimization OFF..." -ForegroundColor Yellow
$do = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (-not (Test-Path $do)) { New-Item -Path $do -Force | Out-Null }
Set-ItemProperty -Path $do -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[6/8] Bandwidth limit 1 Mbps..." -ForegroundColor Yellow
$do2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"
if (-not (Test-Path $do2)) { New-Item -Path $do2 -Force | Out-Null }
Set-ItemProperty -Path $do2 -Name "DownloadRateBackgroundBps" -Value 125000 -Type DWord -Force
Write-Host "  [OK] 1 Mbps" -ForegroundColor Green

Write-Host "[7/8] Telemetry OFF..." -ForegroundColor Yellow
$tel = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $tel)) { New-Item -Path $tel -Force | Out-Null }
Set-ItemProperty -Path $tel -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[8/8] Background Apps OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN v1 - COMPLETED - 8 tweaks" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your PC." -ForegroundColor Yellow
pause

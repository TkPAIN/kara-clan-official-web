# ================================================================
#   KaraClan_OptimizarWindows_v1.ps1
#   Kara Clan — Free Distribution
#   Run as Administrator
#   Vol.1 — Essential (Basic Network Optimization)
# ================================================================

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan — Optimizer v1 (Essential)"
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
Write-Host "   KARA CLAN - OPTIMIZADOR v1" -ForegroundColor Cyan
Write-Host "   Network & Performance — Windows 10/11" -ForegroundColor DarkCyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$tweaks = 0

# ── 1. Nagle OFF (TcpAckFrequency + TCPNoDelay) ────────────────
Write-Host "[>>] TcpAckFrequency + TCPNoDelay (Nagle OFF)..." -ForegroundColor Yellow
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($i in $ifaces) {
    Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Nagle OFF applied to $($ifaces.Count) interfaces" -ForegroundColor Green
$tweaks++

# ── 2. High Performance Power Plan ──────────────────────────────
Write-Host "[>>] High Performance Power Plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
Write-Host "  [OK] High Performance activated" -ForegroundColor Green
$tweaks++

# ── 3. Cloudflare DNS ───────────────────────────────────────────
Write-Host "[>>] Cloudflare DNS (1.1.1.1 / 1.0.0.1)..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
}
Write-Host "  [OK] DNS configured on $($adapters.Count) adapters" -ForegroundColor Green
$tweaks++

# ── 4. Flush DNS Cache ──────────────────────────────────────────
Write-Host "[>>] Flush DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  [OK] DNS cache flushed" -ForegroundColor Green
$tweaks++

# ── 5. Delivery Optimization OFF ────────────────────────────────
Write-Host "[>>] Delivery Optimization OFF..." -ForegroundColor Yellow
$doPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (-not (Test-Path $doPath)) { New-Item -Path $doPath -Force | Out-Null }
Set-ItemProperty -Path $doPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-Host "  [OK] P2P Updates disabled" -ForegroundColor Green
$tweaks++

# ── 6. Background Bandwidth Limit (1 Mbps) ─────────────────────
Write-Host "[>>] Background bandwidth limit (1 Mbps)..." -ForegroundColor Yellow
$doPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"
if (-not (Test-Path $doPath2)) { New-Item -Path $doPath2 -Force | Out-Null }
Set-ItemProperty -Path $doPath2 -Name "DownloadRateBackgroundBps" -Value 125000 -Type DWord -Force
Write-Host "  [OK] Limit set to 1 Mbps" -ForegroundColor Green
$tweaks++

# ── 7. Telemetry OFF ────────────────────────────────────────────
Write-Host "[>>] Telemetry OFF..." -ForegroundColor Yellow
$telPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Telemetry disabled" -ForegroundColor Green
$tweaks++

# ── 8. Background Apps OFF ──────────────────────────────────────
Write-Host "[>>] Background Apps OFF..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Background apps disabled" -ForegroundColor Green
$tweaks++

# ── Footer ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   KARA CLAN — COMPLETED — $tweaks tweaks applied" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Restart your PC for changes to take effect." -ForegroundColor Yellow
Write-Host ""
pause

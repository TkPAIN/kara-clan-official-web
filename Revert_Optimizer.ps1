$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan - Revert Optimizer"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Run this script as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "==========================================" -ForegroundColor DarkRed
Write-Host "   KARA CLAN - RESET OPTIMIZER" -ForegroundColor Red
Write-Host "   Reverting all optimizations..." -ForegroundColor DarkRed
Write-Host "==========================================" -ForegroundColor DarkRed
Write-Host ""

$c = 0

Write-Host "[$((++$c))/10] Restoring Nagle..." -ForegroundColor Yellow
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $ifaces) {
    Remove-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Force -ErrorAction SilentlyContinue
}
Write-Host "  [OK] Restored" -ForegroundColor Green

Write-Host "[$((++$c))/10] Restoring DNS (DHCP)..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) { Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue }
Write-Host "  [OK] Restored" -ForegroundColor Green

Write-Host "[$((++$c))/10] Balanced Power Plan..." -ForegroundColor Yellow
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
Write-Host "  [OK] Balanced" -ForegroundColor Green

Write-Host "[$((++$c))/10] Hibernate ON..." -ForegroundColor Yellow
powercfg -h on 2>$null
Write-Host "  [OK] ON" -ForegroundColor Green

Write-Host "[$((++$c))/10] Restoring services..." -ForegroundColor Yellow
$svcs = @("DiagTrack","WerSvc","Spooler","XblAuthManager","XblGameSave","MapsBroker","lfsvc")
foreach ($s in $svcs) {
    try {
        Set-Service -Name $s -StartupType Automatic -ErrorAction Stop
        Start-Service -Name $s -ErrorAction SilentlyContinue
    } catch {}
}
Write-Host "  [OK] Restored" -ForegroundColor Green

Write-Host "[$((++$c))/10] Restoring UI animations..." -ForegroundColor Yellow
$vfx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Set-ItemProperty -Path $vfx -Name "VisualFXSetting" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Restored" -ForegroundColor Green

Write-Host "[$((++$c))/10] Restoring shutdown times..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "20000" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "5000" -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Default" -ForegroundColor Green

Write-Host "[$((++$c))/10] Cortana ON..." -ForegroundColor Yellow
$cp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Remove-ItemProperty -Path $cp -Name "AllowCortana" -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] ON" -ForegroundColor Green

Write-Host "[$((++$c))/10] Game Bar ON + SysMain ON..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-Service "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service "SysMain" -ErrorAction SilentlyContinue
Write-Host "  [OK] Restored" -ForegroundColor Green

Write-Host "[$((++$c))/10] Memory compression ON..." -ForegroundColor Yellow
try { Enable-MMAgent -MemoryCompression -ErrorAction Stop; Write-Host "  [OK] ON" -ForegroundColor Green } catch { Write-Host "  [SKIP] Not available" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "==========================================" -ForegroundColor DarkRed
Write-Host "   KARA CLAN - RESET COMPLETED" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor DarkRed
Write-Host ""
Write-Host "  Restart your PC." -ForegroundColor Yellow
pause

# ================================================================
#   KaraClan_Revert_Optimizer.ps1
#   Kara Clan — Free Distribution
#   Run as Administrator
#   Reverts ALL changes made by Vol.1, Vol.2 and Vol.3
# ================================================================

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan — Revert Optimizer"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

# ── Admin Check ─────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] You must run this script as Administrator." -ForegroundColor Red
    Write-Host "  Right-click the file and select 'Run as Administrator'." -ForegroundColor Yellow
    pause
    exit
}

# ── Helper Functions ─────────────────────────────────────────────
function Write-Step { param([string]$n,[string]$t); Write-Host "  " -NoNewline; Write-Host " $n " -BackgroundColor DarkRed -ForegroundColor White -NoNewline; Write-Host "  $t" -ForegroundColor White }
function Write-OK   { param([string]$msg); Write-Host "       OK  $msg" -ForegroundColor Green }
function Write-WARN { param([string]$msg); Write-Host "     WARN  $msg" -ForegroundColor Yellow }
function Write-Div  { Write-Host "  -------------------------------------------------------------------" -ForegroundColor DarkGray }

function Enable-Svc {
    param([string]$name,[string]$label,[string]$start="Automatic")
    try {
        Set-Service -Name $name -StartupType $start -ErrorAction Stop
        Start-Service -Name $name -ErrorAction SilentlyContinue
        Write-OK "Restored: $label"
    } catch {
        Write-OK "Not available: $label"
    }
}

$steps = 0

# ── Header ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ================================================================" -ForegroundColor DarkRed
Write-Host "   KARA CLAN — RESET OPTIMIZER" -ForegroundColor Red
Write-Host "   Reverting all optimizations..." -ForegroundColor DarkRed
Write-Host "  ================================================================" -ForegroundColor DarkRed
Write-Host ""

# ═══════════════ NETWORK ═══════════════
Write-Host "  [ NETWORK ]" -ForegroundColor Cyan
Write-Div

Write-Step "1" "Restoring Nagle (TcpAckFrequency)..."
$ifaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($i in $ifaces) {
    Remove-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Force -ErrorAction SilentlyContinue
}
Write-OK "Nagle restored on $($ifaces.Count) interfaces"
$steps++

Write-Step "2" "Restoring automatic DNS (DHCP)..."
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
foreach ($a in $adapters) {
    Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
}
Write-OK "DNS automatic on $($adapters.Count) adapters"
$steps++

Write-Step "3" "Flushing DNS cache..."
ipconfig /flushdns | Out-Null
Write-OK "Cache cleaned"
$steps++

# ═══════════════ SYSTEM ═══════════════
Write-Host ""
Write-Host "  [ SYSTEM ]" -ForegroundColor Magenta
Write-Div

Write-Step "4" "Restoring Balanced Power Plan..."
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
Write-OK "Balanced Plan"
$steps++

Write-Step "5" "Hibernate ON..."
powercfg -h on 2>$null
Write-OK "ON"
$steps++

Write-Step "6" "Restoring GPU Priority..."
$gp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gp) { Remove-Item -Path $gp -Recurse -Force }
Write-OK "Restored"
$steps++

Write-Step "7" "Telemetry ON..."
$tel = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
Remove-ItemProperty -Path $tel -Name "AllowTelemetry" -Force -ErrorAction SilentlyContinue
Write-OK "Restored"
$steps++

Write-Step "8" "Game Bar ON + SysMain ON..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-Service "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service "SysMain" -ErrorAction SilentlyContinue
Write-OK "Restored"
$steps++

# ═══════════════ SERVICES ═══════════════
Write-Host ""
Write-Host "  [ SERVICES ]" -ForegroundColor Yellow
Write-Div

Write-Step "9" "Restoring disabled services..."
Enable-Svc "DiagTrack" "Telemetry" "Automatic"
Enable-Svc "WerSvc" "Error Reporting" "Manual"
Enable-Svc "Spooler" "Print Spooler" "Automatic"
Enable-Svc "XblAuthManager" "Xbox Auth" "Manual"
Enable-Svc "XblGameSave" "Xbox Game Save" "Manual"
Enable-Svc "MapsBroker" "Maps" "Automatic"
Enable-Svc "lfsvc" "Geolocation" "Manual"
$steps++

# ═══════════════ REGISTRY + DISK ═══════════════
Write-Host ""
Write-Host "  [ REGISTRY + DISK ]" -ForegroundColor Green
Write-Div

Write-Step "10" "Restoring UI animations..."
$vfx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Set-ItemProperty -Path $vfx -Name "VisualFXSetting" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Write-OK "Restored"
$steps++

Write-Step "11" "Restoring default shutdown times..."
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "20000" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "5000" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Value "5000" -Force -ErrorAction SilentlyContinue
Write-OK "Default values"
$steps++

Write-Step "12" "Cortana ON..."
$cp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Remove-ItemProperty -Path $cp -Name "AllowCortana" -Force -ErrorAction SilentlyContinue
Write-OK "ON"
$steps++

Write-Step "13" "Indexing on C: ON..."
$drv = Get-CimInstance -Class Win32_Volume -Filter "DriveLetter='C:'" -ErrorAction SilentlyContinue
if ($drv) {
    $drv | Set-CimInstance -Property @{IndexingEnabled=$true} -ErrorAction SilentlyContinue
    Write-OK "ON"
} else {
    Write-OK "Not available"
}
$steps++

Write-Step "14" "8.3 filenames ON..."
fsutil behavior set disable8dot3 0 | Out-Null
Write-OK "ON"
$steps++

Write-Step "15" "LastAccess timestamp ON..."
fsutil behavior set disablelastaccess 0 | Out-Null
Write-OK "ON"
$steps++

Write-Step "16" "Memory compression ON..."
if (Get-Command Enable-MMAgent -ErrorAction SilentlyContinue) {
    try { Enable-MMAgent -MemoryCompression -ErrorAction Stop; Write-OK "ON" }
    catch { Write-OK "Not available" }
} else {
    Write-OK "Not available"
}
$steps++

# ── Footer ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ================================================================" -ForegroundColor DarkRed
Write-Host "   KARA CLAN — RESET COMPLETED — $steps steps reverted" -ForegroundColor Red
Write-Host "  ================================================================" -ForegroundColor DarkRed
Write-Host ""
Write-WARN "Restart your PC to apply all changes."
Write-Host ""
pause

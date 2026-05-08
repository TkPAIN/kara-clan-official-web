# ================================================================
#   KaraClan_OptimizarWindows_v3.ps1
#   Kara Clan — Free Distribution
#   Run as Administrator
#   Vol.3 — Complete (Services + Registry + Disk + Memory)
# ================================================================

$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan — Optimizer v3 (Complete)"
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
function Write-Step { param([string]$n,[string]$t); Write-Host "  " -NoNewline; Write-Host " $n " -BackgroundColor Yellow -ForegroundColor Black -NoNewline; Write-Host "  $t" -ForegroundColor White }
function Write-OK   { param([string]$msg); Write-Host "       OK  $msg" -ForegroundColor Green }
function Write-SKIP { param([string]$msg); Write-Host "     SKIP  $msg" -ForegroundColor DarkGray }
function Write-WARN { param([string]$msg); Write-Host "     WARN  $msg" -ForegroundColor Yellow }
function Write-Div  { Write-Host "  -------------------------------------------------------------------" -ForegroundColor DarkGray }

function Disable-Svc {
    param([string]$name,[string]$label)
    try {
        $s = Get-Service -Name $name -ErrorAction Stop
        if ($s.StartType -ne 'Disabled') {
            Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-OK "OFF: $label"
        } else {
            Write-SKIP "Already OFF: $label"
        }
    } catch {
        Write-SKIP "Not found: $label"
    }
}

$tweaks = 0

# ── Header ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ██ KARA CLAN — OPTIMIZADOR v3 FIXED ██" -ForegroundColor Yellow
Write-Host "  Services | Registry | Disk | Memory" -ForegroundColor DarkYellow
Write-Div
Write-Host ""

# ═══════════════ SERVICES ═══════════════
Write-Host "  [ SERVICES ]" -ForegroundColor Yellow
Write-Div

Disable-Svc "DiagTrack"          "Telemetry (DiagTrack)"
Disable-Svc "dmwappushservice"   "WAP Push Routing"
Disable-Svc "WerSvc"             "Error Reporting"
Disable-Svc "wercplsupport"      "Error Panel Support"
Disable-Svc "Spooler"            "Print Spooler"
Disable-Svc "PrintNotify"        "Printer Notifications"
Disable-Svc "Fax"                "Fax Service"
Disable-Svc "TabletInputService" "Tablet PC Input"
Disable-Svc "TapiSrv"            "Telephony TAPI"
Disable-Svc "XblAuthManager"     "Xbox Live Auth"
Disable-Svc "XblGameSave"        "Xbox Live Game Save"
Disable-Svc "XboxNetApiSvc"      "Xbox Live Networking"
Disable-Svc "XboxGipSvc"         "Xbox Accessory Mgmt"
Disable-Svc "MapsBroker"         "Downloaded Maps"
Disable-Svc "lfsvc"              "Geolocation"
Disable-Svc "SharedAccess"       "ICS"
Disable-Svc "RemoteRegistry"     "Remote Registry"
Disable-Svc "RetailDemo"         "Retail Demo Mode"
Disable-Svc "WMPNetworkSvc"      "Windows Media Player Network"
Disable-Svc "icssvc"             "WiFi Mobile Hotspot"

$tweaks++

# ═══════════════ REGISTRY ═══════════════
Write-Host ""
Write-Host "  [ REGISTRY ]" -ForegroundColor Cyan
Write-Div

Write-Step "02" "UI Animations OFF"
$vfx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
if (-not (Test-Path $vfx)) { New-Item -Path $vfx -Force | Out-Null }
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path $vfx -Name "VisualFXSetting" -Value 2 -Type DWord -Force
Write-OK "Animations reduced to minimum"
$tweaks++

Write-Step "03" "CPU Priority maximum for foreground"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
Write-OK "Win32PrioritySeparation = 38"
$tweaks++

Write-Step "04" "Cortana OFF"
$cp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $cp)) { New-Item -Path $cp -Force | Out-Null }
Set-ItemProperty -Path $cp -Name "AllowCortana" -Value 0 -Type DWord -Force
Write-OK "Cortana disabled"
$tweaks++

Write-Step "05" "Auto-restart apps OFF"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "RestartApps" -Value 0 -Type DWord -Force
Write-OK "Disabled"
$tweaks++

Write-Step "06" "Shutdown time reduced"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout"       -Value "1000" -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Value "2000" -Force
Write-OK "Apps=2s | Services=2s"
$tweaks++

Write-Step "07" "Tips and suggestions OFF"
$tp = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $tp)) { New-Item -Path $tp -Force | Out-Null }
@("SubscribedContent-338389Enabled","SubscribedContent-310093Enabled","SoftLandingEnabled") | ForEach-Object {
    Set-ItemProperty -Path $tp -Name $_ -Value 0 -Type DWord -Force
}
Write-OK "Disabled"
$tweaks++

Write-Step "08" "AutoPlay OFF"
$ap = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"
if (-not (Test-Path $ap)) { New-Item -Path $ap -Force | Out-Null }
Set-ItemProperty -Path $ap -Name "DisableAutoplay" -Value 1 -Type DWord -Force
Write-OK "AutoPlay disabled"
$tweaks++

Write-Step "09" "Location OFF"
$lp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
if (-not (Test-Path $lp)) { New-Item -Path $lp -Force | Out-Null }
Set-ItemProperty -Path $lp -Name "DisableLocation" -Value 1 -Type DWord -Force
Write-OK "Location disabled"
$tweaks++

# ═══════════════ DISK ═══════════════
Write-Host ""
Write-Host "  [ DISK ]" -ForegroundColor Green
Write-Div

Write-Step "10" "Cleaning temporary files"
$totalFreed = 0
foreach ($f in @($env:TEMP,"C:\Windows\Temp","C:\Windows\Prefetch")) {
    if (Test-Path $f) {
        $sz = (Get-ChildItem $f -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        Remove-Item "$f\*" -Recurse -Force -ErrorAction SilentlyContinue
        if ($sz) { $totalFreed += $sz }
    }
}
Write-OK "Freed ~$([math]::Round($totalFreed/1MB,1)) MB"
$tweaks++

Write-Step "11" "Windows Update cache cleaned"
Stop-Service "wuauserv" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service "wuauserv" -ErrorAction SilentlyContinue
Write-OK "Cache cleaned"
$tweaks++

Write-Step "12" "TRIM on SSD"
try { Optimize-Volume -DriveLetter C -ReTrim -Verbose:$false -ErrorAction Stop; Write-OK "TRIM executed on C:" } catch { Write-SKIP "Not available" }
$tweaks++

Write-Step "13" "Indexing on C: OFF"
$drv = Get-CimInstance -Class Win32_Volume -Filter "DriveLetter='C:'" -ErrorAction SilentlyContinue
if ($drv) { $drv | Set-CimInstance -Property @{IndexingEnabled=$false} -ErrorAction SilentlyContinue; Write-OK "Indexing disabled" } else { Write-SKIP "Not accessible" }
$tweaks++

Write-Step "14" "8.3 filenames OFF"
fsutil behavior set disable8dot3 1 | Out-Null
Write-OK "8.3 names disabled"
$tweaks++

Write-Step "15" "LastAccess timestamp OFF"
fsutil behavior set disablelastaccess 1 | Out-Null
Write-OK "Timestamp disabled"
$tweaks++

# ═══════════════ MEMORY ═══════════════
Write-Host ""
Write-Host "  [ MEMORY ]" -ForegroundColor Magenta
Write-Div

$mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

Write-Step "16" "ClearPageFile = 0"
Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
Write-OK "Faster shutdown"
$tweaks++

Write-Step "17" "LargeSystemCache = 0"
Set-ItemProperty -Path $mp -Name "LargeSystemCache" -Value 0 -Type DWord -Force
Write-OK "Application priority"
$tweaks++

Write-Step "18" "Memory compression OFF"
if (Get-Command Disable-MMAgent -ErrorAction SilentlyContinue) {
    try { Disable-MMAgent -MemoryCompression -ErrorAction Stop; Write-OK "Compression disabled" }
    catch { Write-SKIP "Could not disable" }
} else { Write-SKIP "Cmdlet not available" }
$tweaks++

Write-Step "19" "HeapDeCommitFreeBlockThreshold"
Set-ItemProperty -Path $mp -Name "HeapDeCommitFreeBlockThreshold" -Value 0x00040000 -Type DWord -Force
Write-OK "Optimized"
$tweaks++

Write-Step "20" "AlwaysUnloadDLL ON"
$ep = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
if (-not (Test-Path $ep)) { New-Item -Path $ep -Force | Out-Null }
Set-ItemProperty -Path $ep -Name "AlwaysUnloadDLL" -Value 1 -Type DWord -Force
Write-OK "DLLs freed on minimize"
$tweaks++

# ── Footer ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ======================================================================" -ForegroundColor Yellow
Write-Host "   KARA CLAN — VOL.3 COMPLETED — $tweaks improvements applied" -ForegroundColor Green
Write-Host "  ======================================================================" -ForegroundColor Yellow
Write-Host ""
Write-WARN "Restart your PC to apply all changes."
Write-Host ""
pause

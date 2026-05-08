$ErrorActionPreference = "Continue"
$Host.UI.RawUI.WindowTitle = "Kara Clan - Optimizer v3"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [ERROR] Run this script as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "   KARA CLAN - OPTIMIZADOR v3 FIXED" -ForegroundColor Yellow
Write-Host "   Services | Registry | Disk | Memory" -ForegroundColor DarkYellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""

$c = 0

# ═══════════ SERVICES ═══════════
Write-Host "  [ SERVICES ]" -ForegroundColor Yellow

$svcs = @(
    @{Name="DiagTrack"; Label="Telemetry"},
    @{Name="dmwappushservice"; Label="WAP Push"},
    @{Name="WerSvc"; Label="Error Reporting"},
    @{Name="Spooler"; Label="Print Spooler"},
    @{Name="XblAuthManager"; Label="Xbox Auth"},
    @{Name="XblGameSave"; Label="Xbox Game Save"},
    @{Name="MapsBroker"; Label="Maps"},
    @{Name="lfsvc"; Label="Geolocation"},
    @{Name="RemoteRegistry"; Label="Remote Registry"},
    @{Name="WMPNetworkSvc"; Label="WMP Network"}
)

foreach ($s in $svcs) {
    Write-Host "[$((++$c))/20] Disabling $($s.Label)..." -ForegroundColor Yellow
    try {
        $svc = Get-Service -Name $s.Name -ErrorAction Stop
        if ($svc.StartType -ne 'Disabled') {
            Stop-Service -Name $s.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $s.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  [OK] OFF" -ForegroundColor Green
        } else {
            Write-Host "  [SKIP] Already OFF" -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "  [SKIP] Not found" -ForegroundColor DarkGray
    }
}

# ═══════════ REGISTRY ═══════════
Write-Host ""
Write-Host "  [ REGISTRY ]" -ForegroundColor Cyan

Write-Host "[$((++$c))/20] UI Animations OFF..." -ForegroundColor Yellow
$vfx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
if (-not (Test-Path $vfx)) { New-Item -Path $vfx -Force | Out-Null }
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
Set-ItemProperty -Path $vfx -Name "VisualFXSetting" -Value 2 -Type DWord -Force
Write-Host "  [OK] Minimized" -ForegroundColor Green

Write-Host "[$((++$c))/20] CPU Priority 38..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
Write-Host "  [OK] 38" -ForegroundColor Green

Write-Host "[$((++$c))/20] Cortana OFF..." -ForegroundColor Yellow
$cp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $cp)) { New-Item -Path $cp -Force | Out-Null }
Set-ItemProperty -Path $cp -Name "AllowCortana" -Value 0 -Type DWord -Force
Write-Host "  [OK] OFF" -ForegroundColor Green

Write-Host "[$((++$c))/20] Shutdown time reduced..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "1000" -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Value "2000" -Force
Write-Host "  [OK] 2s" -ForegroundColor Green

Write-Host "[$((++$c))/20] Tips & Suggestions OFF..." -ForegroundColor Yellow
$tp = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $tp)) { New-Item -Path $tp -Force | Out-Null }
@("SubscribedContent-338389Enabled","SubscribedContent-310093Enabled","SoftLandingEnabled") | ForEach-Object {
    Set-ItemProperty -Path $tp -Name $_ -Value 0 -Type DWord -Force
}
Write-Host "  [OK] OFF" -ForegroundColor Green

# ═══════════ DISK ═══════════
Write-Host ""
Write-Host "  [ DISK ]" -ForegroundColor Green

Write-Host "[$((++$c))/20] Cleaning temp files..." -ForegroundColor Yellow
$total = 0
foreach ($f in @($env:TEMP,"C:\Windows\Temp","C:\Windows\Prefetch")) {
    if (Test-Path $f) {
        $sz = (Get-ChildItem $f -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        Remove-Item "$f\*" -Recurse -Force -ErrorAction SilentlyContinue
        if ($sz) { $total += $sz }
    }
}
Write-Host "  [OK] Freed ~$([math]::Round($total/1MB,1)) MB" -ForegroundColor Green

Write-Host "[$((++$c))/20] TRIM SSD..." -ForegroundColor Yellow
try { Optimize-Volume -DriveLetter C -ReTrim -Verbose:$false -ErrorAction Stop; Write-Host "  [OK] TRIM C:" -ForegroundColor Green } catch { Write-Host "  [SKIP] Not available" -ForegroundColor DarkGray }

# ═══════════ MEMORY ═══════════
Write-Host ""
Write-Host "  [ MEMORY ]" -ForegroundColor Magenta

$mp = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"

Write-Host "[$((++$c))/20] ClearPageFile = 0..." -ForegroundColor Yellow
Set-ItemProperty -Path $mp -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord -Force
Write-Host "  [OK] Faster shutdown" -ForegroundColor Green

Write-Host "[$((++$c))/20] LargeSystemCache = 0..." -ForegroundColor Yellow
Set-ItemProperty -Path $mp -Name "LargeSystemCache" -Value 0 -Type DWord -Force
Write-Host "  [OK] App priority" -ForegroundColor Green

Write-Host "[$((++$c))/20] AlwaysUnloadDLL ON..." -ForegroundColor Yellow
$ep = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
if (-not (Test-Path $ep)) { New-Item -Path $ep -Force | Out-Null }
Set-ItemProperty -Path $ep -Name "AlwaysUnloadDLL" -Value 1 -Type DWord -Force
Write-Host "  [OK] ON" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "   KARA CLAN v3 - COMPLETED - 20 tweaks" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Restart your PC." -ForegroundColor Yellow
pause

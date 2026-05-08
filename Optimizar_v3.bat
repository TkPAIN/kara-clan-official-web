@echo off
title Kara Clan - Optimizer Vol.3
echo Downloading and running Kara Clan Optimizer Vol.3...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.github.com/TkPAIN/kara-clan-official-web/blob/main/OptimizarWindows_v3.ps1'; Invoke-Expression $s }"
pause

@echo off
title Kara Clan - Optimizer Vol.3
echo Downloading and running Kara Clan Optimizer Vol.3...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-win-op/main/OptimizarWindows_v3.ps1'; Invoke-Expression $s }"
pause

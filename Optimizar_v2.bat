@echo off
title Kara Clan - Optimizer Vol.2
echo Downloading and running Kara Clan Optimizer Vol.2...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-win-op/main/OptimizarWindows_v2.ps1'; Invoke-Expression $s }"
pause

@echo off
title Kara Clan - Optimizer Vol.1
echo Downloading and running Kara Clan Optimizer Vol.1...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-win-op/main/OptimizarWindows_v1.ps1'; Invoke-Expression $s }"
pause

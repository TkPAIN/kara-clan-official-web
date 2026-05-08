@echo off
title Kara Clan - Optimizer Vol.1
echo Kara Clan Optimizer Vol.1 — Essential
echo.
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-win-op/main/OptimizarWindows_v1.ps1'; Invoke-Expression $s }"
pause

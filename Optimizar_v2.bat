@echo off
title Kara Clan - Optimizer Vol.2
echo Kara Clan Optimizer Vol.2 — Advanced
echo.
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-official-web/main/OptimizarWindows_v2.ps1'; Invoke-Expression $s }"
pause

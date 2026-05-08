@echo off
title Kara Clan - Optimizer Vol.1
echo Kara Clan Optimizer Vol.1 — Essential
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.https://github.com/TkPAIN/kara-clan-official-web/blob/main/OptimizarWindows_v1.ps1'; Invoke-Expression $s }"
pause

@echo off
title Kara Clan - Optimizer Vol.2
echo Kara Clan Optimizer Vol.2 — Advanced
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.github.com/TkPAIN/kara-clan-official-web/blob/main/OptimizarWindows_v2.ps1'; Invoke-Expression $s }"
pause

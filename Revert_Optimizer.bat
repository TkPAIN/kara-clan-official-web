@echo off
title Kara Clan - Revert Optimizer
echo Kara Clan Revert Optimizer — Restore Defaults
echo.
echo Downloading and running...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-official-web/main/Revert_Optimizer.ps1'; Invoke-Expression $s }"
pause

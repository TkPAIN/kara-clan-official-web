@echo off
title Kara Clan - Revert Optimizer
echo Downloading and running Kara Clan Revert Optimizer...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { $s = Invoke-RestMethod 'https://raw.githubusercontent.com/TkPAIN/kara-clan-win-op/main/Revert_Optimizer.ps1'; Invoke-Expression $s }"
pause

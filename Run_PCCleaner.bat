@echo off
:: ============================================================
::  PC Deep Cleaner — Launcher
::  Double-click this file. It will auto-request Admin rights.
::  Both this .bat and PCCleaner.ps1 must be in the same folder.
:: ============================================================

:: Check if already admin
net session >nul 2>&1
if %errorLevel% == 0 goto :run

:: Not admin — re-launch self elevated, hidden window, auto-closes when done
powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs -WindowStyle Hidden"
exit /b

:run
:: Launch the PowerShell GUI in STA mode (required for WPF), hidden CMD host
powershell.exe -NoProfile -ExecutionPolicy Bypass -Sta -WindowStyle Hidden -File "%~dp0PCCleaner.ps1"

:: Only pause on error so the user can read it; window closes silently on success
if %errorLevel% neq 0 (
    echo.
    echo ERROR: PowerShell exited with code %errorLevel%
    echo Make sure PCCleaner.ps1 is in the same folder as this .bat file.
    pause
)
:: CMD window auto-closes here on success
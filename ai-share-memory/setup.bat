@echo off
title AI Share Memory Setup

echo ================================================
echo   AI Share Memory - Setup
echo   OpenClaw x Claude Code Handoff
echo ================================================
echo.
echo Starting configuration script...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

echo.
echo Press any key to exit...
pause >nul

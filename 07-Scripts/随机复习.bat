@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo ========================================
echo         知识库随机复习
echo ========================================
echo.

set /p count="请输入复习数量(默认5): "
if "%count%"=="" set count=5

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\random-review.ps1" -Count %count%

pause

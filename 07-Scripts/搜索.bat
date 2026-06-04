@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo ========================================
echo         知识库搜索工具
echo ========================================
echo.

set /p query="请输入搜索关键词: "

powershell -ExecutionPolicy Bypass -File "%~dp0scripts\search-knowledgebase.ps1" -Query "%query%"

echo.
pause

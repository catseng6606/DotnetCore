#!/bin/bash

# 尋找並停止現有的 dotnet 程序 (排除當前腳本)
echo "正在清理現有的 dotnet 程序..."
pkill -f "dotnet run" || true
pkill -f "{project}" || true
sleep 1

echo "正在啟動專案 (Release 模式)..."
cd {project}
dotnet run --configuration Release

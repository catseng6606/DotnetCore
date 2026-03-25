#!/bin/bash

# 尋找並停止現有的 dotnet 程序
echo "正在清理現有的 dotnet 程序..."
pkill -f "dotnet run" || true
pkill -f "{project}" || true
sleep 1

echo "正在以偵錯模式啟動專案 (Watch 模式)..."
cd {project}
dotnet watch run

#!/bin/bash

# ==========================================
# Azure 部署自動化腳本 (deploy.sh)
# 用於將本地開發分支同步至 Azure App Service 的部署分支
# ==========================================
# 進入你的專案根目錄
# cd {project}
# 初始化為 Git 儲存庫
# git init
# 新增所有檔案並提交第一次 commit
# git add .
# git commit -m "Initial commit of ASP.NET Core project"
# 請將 URL 替換成你在 Azure 上看到的實際位址
# git remote add azure <你的 Azure Git URL>
# git push azure main:master
# --- 參數設定 ---
DEPLOY_REMOTE="azure"
DEPLOY_BRANCH="master"
AZURE_GIT_URL="https://{azuresites}.scm.azurewebsites.net:443/tkutimespmtku.git"

# 取得目前分支名稱
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 檢查是否有設定 azure remote
if ! git remote | grep -q "^${DEPLOY_REMOTE}$"; then
    echo "⚠️ 偵測到尚未設定 ${DEPLOY_REMOTE} 遠端倉庫。"
    echo "使用指令: git remote add ${DEPLOY_REMOTE} ${AZURE_GIT_URL}"
    read -p "是否要現在自動新增 ${DEPLOY_REMOTE} 遠端？ (y/n): " add_remote
    if [[ $add_remote == "y" ]]; then
        git remote add ${DEPLOY_REMOTE} ${AZURE_GIT_URL}
        echo "✅ 已完成 ${DEPLOY_REMOTE} 遠端設定。"
    else
        echo "❌ 缺乏 ${DEPLOY_REMOTE} 遠端設定，部署無法繼續。"
        exit 1
    fi
fi

echo "-------------------------------------------"
echo "🚀 正在啟動 Azure 部署程序..."
echo "📍 目前本地分支: ${current_branch}"
echo "-------------------------------------------"

# 檢查是否有未提交的變更 (選配)
if [[ -n $(git status -s) ]]; then
    echo "⚠️ 警告: 您的本地有未提交的變更。建議先 commit 再發行。"
    read -p "是否繼續執行部署？(y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "❌ 部署已中止。"
        exit 1
    fi
fi

# 執行推送指令
# 使用 :${DEPLOY_BRANCH} 是因為 Azure 設定的部署分支
# 使用 --force 是因為兩端歷史分支目前不一致 (non-fast-forward)
echo "⌛ 正在推送 ${current_branch} 至 ${DEPLOY_REMOTE}/${DEPLOY_BRANCH}..."
git push ${DEPLOY_REMOTE} ${current_branch}:${DEPLOY_BRANCH} --force

if [ $? -eq 0 ]; then
    echo "-------------------------------------------"
    echo "✅ 部署指令執行成功！"
    echo "🌐 Azure 正在背景執行建置，請稍候 1-3 分鐘即可看到更新。"
    echo "-------------------------------------------"
else
    echo "-------------------------------------------"
    echo "❌ 部署過程中發生錯誤，請檢查 Git 錯誤訊息。"
    echo "-------------------------------------------"
    exit 1
fi

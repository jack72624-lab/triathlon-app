#!/bin/bash
# 由 Jack 本人執行：建 GitHub 公開 repo + 推送 + 開 GitHub Pages。
# （Claude 自動模式會被安全分類器擋下「對外發佈」動作，所以交給你跑。）
set -e
cd "$(dirname "$0")"

gh repo create jack72624-lab/triathlon-app --public --source . --remote origin --push \
  --description "三鐵訓練 App — CT226 打卡 + Strava 對應 + Claude 週回顧（v1 前端 demo）"

# 開 GitHub Pages（main 分支 / 根目錄）
gh api -X POST /repos/jack72624-lab/triathlon-app/pages \
  -f "source[branch]=main" -f "source[path]=/" 2>/dev/null || echo "(Pages 可能已啟用或稍後再試)"

echo ""
echo "完成。約 1 分鐘後開： https://jack72624-lab.github.io/triathlon-app/"

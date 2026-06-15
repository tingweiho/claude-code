# Claude Code 實戰手冊（繁體中文版）

互動式課程，分享我實際使用 Claude Code 的完整系統：技能庫、自動化 hooks、記憶功能與真實使用情境。

## → [開啟課程](https://tingweiho.github.io/claude-code/playbook-zh/)

或 clone 專案後直接開啟 `index.html`，不需要任何環境設定。

## 課程內容

| 單元 | 主題 |
|---|---|
| 1 | 系統架構 — `~/.claude/` 作為操作核心 |
| 2 | 技能庫 — 隨需載入的可重用能力 |
| 3 | 使用情境 — 我實際拿來做什麼 |
| 4 | 自動化 — hooks、排程與背景代理 |
| 5 | 記憶功能 — 跨對話的持久脈絡 |
| 6 | 最佳實踐 — 哪些有效、哪些沒用 |
| 7 | 資源整理 |

## 檔案結構

```
index.html      ← 課程主檔（直接開啟這個）
styles.css      ← 樣式表
main.js         ← 互動邏輯
assets/         ← 圖示 SVGs
src/            ← 原始檔
  _base.html    ← 框架（標題、導覽）
  modules/      ← 每個單元一支 HTML 檔
  build.sh      ← 重新建置：bash src/build.sh
```

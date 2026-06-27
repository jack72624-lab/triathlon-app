# Design Brief — Tri Plan（三鐵訓練打卡 App）

> 把這份 + `index.html` 一起貼給設計工具/Claude。原始檔：
> https://raw.githubusercontent.com/jack72624-lab/triathlon-app/main/index.html

## 1. 它是什麼
個人用的三鐵（Ironman 226）訓練打卡 App。手機優先、單檔 HTML/CSS/JS。
使用者每天勾完成的課、看當週課表、看 Strava 自動對應、看 12 週總覽。

## 2. 目標：只重做「視覺」
**請只改 CSS（與必要的 class 命名），不要動邏輯。** 現況視覺是從一個記帳 App 借來的「金融感」，放在運動 App 上太商務、不夠有活力——這就是要解決的問題。

## 3. 想要的風格（可改這段）
**方向：乾淨、運動感、有激勵性、數據導向。** 不要金融/商務感。
參考可挑：**Apple Fitness（圓環、留白、清爽）**、**Whoop（沉穩高級、數據環）**、**Strava（活力、橘色重點、卡片數據）**、**Nike Run Club（大字、高對比）**。
> 使用者：挑 1–2 個參考、或寫你要的氛圍（顏色、明/暗、圓潤/銳利）。

## 4. 畫面與元件（要重設計這些）
- **登入頁**：app icon、標題、Google 登入鈕（深色全屏）。
- **Nav**：標題、同步狀態 badge、使用者頭像 + 下拉選單。
- **This Week**：週標題 + **進度環(%)**；每日一張卡，卡內**每堂課一列**（課名 + 等級標籤 + 勾選框）。
- **Strava 區**：頂部統計（Matched / Bonus / Missing）+ 活動卡（圖示、距離/時間、狀態色條、bonus 的 Count/Skip 鈕）。
- **Overview**：12 週列表（週次、期別、日期、每週進度條、完成數）。
- **Segmented**：This Week / Overview 切換。

## 5. 一定要保留的語意色（可換色，但語意別混）
Key（核心/必做）、Keep（維持）、Flex（彈性）、Matched=綠、Bonus=琥珀、Missing=紅、Strava 橘 #fc5200。

## 6. 技術鐵則（不遵守 App 會壞）
- **不要改**：`firebaseConfig`、資料物件（`W`、`DATE`、`SAMPLE_ACTS`）、邏輯函式（`sessionsOf`、`matchWeek`、`startSync`、`push`、`renderWeek`、`renderOv` 的 JS 邏輯）。
- **不要改**這些元素 id：`#auth #shell #sync #sync-text #mode-pill #signin-label #auth-note #user-btn #user-menu #menu-name #menu-email #segWeek #segOv #weekView #ovView #foot`。
- **不要改**這些 handler 名稱（onclick 在用）：`toggle(di,si)`、`exAct(id,yes)`、`setMode('week'|'ov')`、`toggleMenu()`、`doSignOut()`。
- 卡片 HTML 是在 `renderWeek/renderOv` 的 template string 裡組的——若改 class 名，**要同時改 `<style>` 和那些 template string**。
- 可用字型：Manrope、Noto Sans TC（已載入）；可換但附 fallback。

## 7. 交付格式
回傳**整份改好的 `index.html`**（方便直接替換 + 我這邊比對重接）。若只給 `<style>`，請註明哪些 class 名有變動。

## 8. 現況色票（可全換）
深藍 nav/登入 `#0f1020→#1e2038`、淺灰底 `#f4f5f7`、白卡、圓角 16、Manrope 數字。

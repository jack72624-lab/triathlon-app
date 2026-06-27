# 三鐵訓練 App

Challenge Taiwan 226（2027-04-24）訓練追蹤——**打卡 + Strava 自動對應當週課表 + Claude 每週回顧調整強度**。
是 `三鐵訓練計劃` 的工具化延伸。完整規劃見 [`PLAN.md`](PLAN.md)。

## 現況：程式碼完整、待你接 Firebase/Strava 上線

- `index.html`：單檔 App（真 Firebase Auth + Firestore 同步寫法，沿用「收入分配」已驗證版本），風格對齊收入分配。
- **聰明 fallback**：未貼 `firebaseConfig` 時自動退**本機模式**（localStorage），GitHub Pages 連結照樣可預覽；貼上 config + `firebase deploy` 即為**雲端登入同步**真 App。
- 功能：Google 登入、本週課表打卡（雲端持久/多裝置）、月總覽、Strava 活動依**當週課池**比對（對應/額外/漏，換日多跑不誤判）、額外活動一鍵算/不算。
- **還需你做**（要帳號 + 部署，Claude 自動模式做不到）：建 Firebase 專案、貼 config、Strava API、n8n。見 [`SETUP.md`](SETUP.md) / [`N8N.md`](N8N.md)。第一次部署可能要跟 Claude 做一輪小修（程式碼未經實測）。

## 架構（Stack B）

```
[Strava] --輪詢(只讀 Run/Ride/Swim)--> [n8n-local on Mac]
                                          ├─→ training-log.csv (Mac)  ← Claude 每週讀
                                          └─→ Firestore (雲端)        ← App 顯示
                            [Firebase Hosting + Auth(Google)] 手機打卡/看課表
```

**設計鐵則**：抓取器是可替換零件、只認固定 schema → 未來 1–2h 可換成 always-on 的 Firebase 排程函式，App / 資料結構不動。

## 比對邏輯（重點）

依**當週課池**比對（非綁死星期幾），所以**換日、多跑都不誤判**；只在週末結算才判定漏課。詳見 `PLAN.md` §4。

## 檔案

| 檔案 | 用途 |
|---|---|
| `index.html` | App 本體（真 Firebase；未貼 config 退本機模式） |
| `PLAN.md` | 完整規劃（架構/schema/比對/範圍） |
| `SETUP.md` | 接 Firebase + Strava + n8n 的步驟 |
| `N8N.md` | n8n 抓 Strava → Firestore + CSV 的 workflow |
| `firestore.rules` | Firestore 安全規則（每人只讀寫自己） |
| `publish.sh` | 建 repo + 推 + 開 Pages（Jack 自跑） |

課表內容來源：`../週1-12課表.md`（一致性導入期 12 週）。

## 狀態

v1 前端 demo 完成、待 Jack 看過版面。後端（Firebase/Strava/n8n）為下一階段，需 Jack 的帳號與 `firebase deploy`。三方審查（取捨/可行性/體驗）+ 核可閘門尚未跑，留待後端階段前補。

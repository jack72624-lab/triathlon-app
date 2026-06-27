# 三鐵訓練 App

Challenge Taiwan 226（2027-04-24）訓練追蹤——**打卡 + Strava 自動對應當週課表 + Claude 每週回顧調整強度**。
是 `三鐵訓練計劃` 的工具化延伸。完整規劃見 [`PLAN.md`](PLAN.md)。

## 現況：v1 前端 demo

- `index.html`：單檔前端，**mock 資料**，風格對齊「收入分配」（深藍漸層登入/nav、淺灰白卡、Manrope 字）。
- 功能展示：登入畫面、本週課表打卡、月總覽、Strava 活動對應（對應/額外/漏）、額外活動一鍵算/不算。
- **尚未接後端**：登入是 mock、Strava 是 sample 資料。要變成能用的 App 見 [`SETUP.md`](SETUP.md)。

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
| `index.html` | v1 前端（mock） |
| `PLAN.md` | 完整規劃（架構/schema/比對/範圍） |
| `SETUP.md` | 接 Firebase + Strava + n8n 的步驟 |

課表內容來源：`../週1-12課表.md`（一致性導入期 12 週）。

## 狀態

v1 前端 demo 完成、待 Jack 看過版面。後端（Firebase/Strava/n8n）為下一階段，需 Jack 的帳號與 `firebase deploy`。三方審查（取捨/可行性/體驗）+ 核可閘門尚未跑，留待後端階段前補。

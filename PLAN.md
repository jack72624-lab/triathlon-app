# 三鐵訓練 Web App — PLAN（v1）

> 草案 v0.1（2026-06-27）。`三鐵訓練計劃` 的工具化延伸：把打卡 + Strava 自動入帳 + 教練回饋圈做成 App。
> 狀態：plan-pipeline 階段 1 草案，待三方審查與核可。

---

## 1. 目標與定位

- **主目標**：讓 Claude 看得到 Jack 的**真實訓練數據**，每週做「實際 vs 計畫 + 要不要調強度」回顧。這是整個 App 的核心價值——光打勾不夠，要有實際數據。
- **次目標（明示）**：當作練習「手邊製作工具」的機會——學 Firebase（Hosting/Firestore/Auth）+ n8n（自動化）。所以接受比「純訓練追蹤所需」更完整的做法。
- **誠實註記**：純訓練追蹤的最省解是「現有 HTML 打卡 + n8n→CSV + Claude 讀」，不需 App。做 App 是為了體驗 + 學習，是清醒的選擇。

## 2. 架構決定（Stack B，已於 office-hours 鎖定）

```
[Strava]  --輪詢(只讀 Run/Ride/Swim)-->  [n8n-local on Mac]
                                              |
                              +---------------+----------------+
                              v                                v
                   training-log.csv (Mac)              Firestore (雲端)
                   ← Claude 每週讀                       ← App 讀/顯示
                                                              ^
                                              [Firebase Hosting + Auth(Google)]
                                                   手機開 App、打卡、看課表
```

- **App**：Firebase Hosting + Firestore + Auth（Google 登入），學「收入分配」那套（手動 `firebase deploy`、authDomain 同源）。
- **抓取器**：n8n-local 排程輪詢 Strava → 寫 Firestore（給 App）+ 落 `training-log.csv` 到 Mac（給 Claude 讀）。
- **Claude 讀資料**：直接讀 Mac 上的 `training-log.csv`（沿用 weight-log/food-log 模式，我不持任何雲端金鑰）。
- **設計鐵則（讓未來可遷移）**：**抓取器是可替換零件，只認一個固定 schema**。未來要換成 always-on 的 Firebase 排程函式時，只重做抓取器（~1–2h），App / Firestore 結構 / Claude 讀法都不動。
- **已知取捨**：n8n 在 Mac 上，Strava 只在 Mac 開著時抓（會補抓自上次以來的活動）。前提＝Jack 大多數日子會開 Mac。

## 3. 資料契約（穩定的那一層，先定死）

`training-log` 每筆一場訓練（Firestore doc + CSV 一列）：

| 欄位 | 來源 | 說明 |
|---|---|---|
| date | Strava | 活動日期 |
| sport_type | Strava | Run / Ride / Swim（只讀這三種） |
| distance_km | Strava | 距離 |
| duration | Strava | 移動時間 |
| avg_hr | Strava | 平均心率（有戴錶才有） |
| avg_power / IF | Strava | 騎車平均功率（對照 IF 0.68–0.72） |
| elevation | Strava | 爬升 |
| rpe | Strava 主觀感受 | Strava「這次感覺如何」有填就帶（1–10） |
| planned | 課表 | 當日課表排的內容（比對得到才有） |
| match_status | 系統 | 對應 / 額外(bonus) / 漏；另記 計畫 vs 實際 delta（過/不足） |
| notes | 手動 | 備註 |

## 4. Strava 讀取與比對（驗收條件 #2 的細節）

- **只讀 Run / Ride / Swim**：Walk(散步)、Hike(爬山) 與其他類型**根本不抓進來**。
- **以「當週課池」比對，日期只當提示**（資料來源＝`週1-12課表.md` 結構化後的課表）。比對綁「當週要還的課」而非綁死星期幾——這樣才不會跟計畫本身的「可平移/對調」彈性打架：
  - **對應**：一筆活動進來，去當週**同項目、還沒被對應**的計畫課找配對；配到就算完成，**不管哪天做的**。所以「週三週四對調」自動成立，App 可顯示「你把週四的跑挪到週三了」。
  - **多做/多跑不算錯**：計畫 5k 你跑 8k → 配對成功、記實際、標 +3k delta。達標或超標都算完成，**永不因「做更多」被扣**。
  - **額外(bonus)**：當週同項目已配完、你又多做一場 → App 顯示「算訓練嗎？」一鍵算/不算。
  - **漏**：到**週末結算**仍有計畫課沒被任何活動對應 → 標漏課（接 PLAN.md §10，Claude 週回顧處理）。綁當週課池，所以晚一兩天做不誤報漏。

## 5. v1 範圍（先做哪塊就有大部分價值）

**做**：
1. Google 登入（Firebase Auth）。
2. 本週課表 + 打卡（雲端持久、多裝置），課表資料 seed 自現有 HTML 線框圖的週資料。
3. n8n 自動抓 Strava（只 Run/Ride/Swim）→ Firestore + training-log.csv。
4. 當日比對：App 顯示「計畫 vs 實際 + match_status」，額外活動一鍵確認。
5. Claude 每週讀 training-log.csv → 產「實際 vs 計畫 + 要不要調強度」回顧（**離線、不做進 App**）。

**v1 明確不做**：見 §7。

## 6. 與既有系統接點（零重造）

- 課表資料：直接用現有 `週1-12課表.md` / HTML 週資料結構，不重編。
- 數據落點：`training-log.csv` 與既有 `weight-log.csv`、`food-log.csv` 同模式、同目錄概念，Claude 一起讀。
- 營養/體重：維持 triathlon-fuel 既有流程，不併進這個 App。
- 週回顧：可掛進既有「週日彙整」launchd 排程。

## 7. 明確不做的事（YAGNI）

- **不做 in-app AI 教練**（強度調整＝Claude 離線週回顧；App 只負責記錄與顯示）。
- **不做趨勢圖表/儀表板**（v2；且圖表要先有資料累積才有意義）。
- **不做 always-on Firebase 函式**（v2 升級；現在 n8n 夠用，且鐵則保證好遷移）。
- **不用 Strava webhook**（要公開網址，n8n-local 收不到；用輪詢）。
- **不做多使用者 / 分享**（個人自用）。
- **不做課表編輯器**（43 週動態編輯、本週微調換課都 v2；v1 靠「當週課池比對」自動吸收換日/多跑，課表先當 seed 資料）。

## 8. 風險與前置條件

| 項目 | 內容 |
|---|---|
| 前置 | ① Strava 開 API application（Client ID/Secret）+ 一次 OAuth 授權 ② n8n 建 Strava 節點 + 排程 + 欄位對應 ③ Firebase 專案（可沿用既有或新開） |
| 安全 | Strava secret / n8n credential 不進 git；Claude 讀本機 CSV、不持雲端金鑰；Firebase 規則限本人讀寫 |
| 條款 | Strava API 近年收緊「對外把資料餵 AI」；個人自用自己資料 OK，別做成對外產品 |
| 部署 | `firebase deploy` 由 Jack 自己跑（自動模式會擋部署/密鑰，見既有踩坑記錄） |
| 資料品質 | 心率/功率/RPE 要戴錶、Strava 有填才有；沒有時退而用距離/時間/主觀 |

## 9. 驗收條件（v1）

1. 手機開 App、Google 登入、看本週課表並打卡，資料**雲端持久、換裝置不掉**。
2. 系統**只讀取 Strava Run/Ride/Swim**，依**當週課池**（日期當提示）比對課表，標記 對應/額外/漏；換日、多跑都不誤判。
3. 每週 **Claude 讀得到實際數據**，產出「實際 vs 計畫 + 要不要調強度」回顧。

## 10. 下一步任務清單（核可後）

1. 把現有 12 週課表轉成結構化 seed 資料（Firestore 課表 collection）。
2. 建 Firebase 專案骨架（Hosting+Firestore+Auth），登入 + 本週打卡頁。
3. Strava API app 申請 + n8n 輪詢 workflow（只 Run/Ride/Swim）→ Firestore + training-log.csv。
4. 當日比對邏輯 + 額外活動確認 UI。
5. 接 Claude 週回顧（讀 training-log.csv）。
6. Jack `firebase deploy` 上線、手機實測。

---

*接 plan-pipeline 階段 2：三方審查（取捨官 + 可行性官 + 體驗官，可行性官上網查 Strava API / Firebase 限制）。*

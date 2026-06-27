# n8n 設定 — 自動抓 Strava → Firestore + training-log.csv

在既有 `~/Downloads/n8n-local` 建一個 workflow。**只抓 Run/Ride/Swim**，依資料契約寫入。Mac 開著時才跑（會補抓自上次以來的活動）。

## 前置
- Strava：`strava.com/settings/api` 建 App → Client ID/Secret → 跑一次 OAuth 拿 refresh token（scope `activity:read`）。
- Firebase：下載 service account 金鑰（專案設定 → 服務帳戶 → 產生新私密金鑰）。**金鑰不進 git**（放 n8n credential 或本機 `.env`）。
- 你的 Firebase `uid`：登入 App 後在 console 或從 Firestore `users` 看得到。

## Workflow 節點
1. **Schedule Trigger**：每 3 小時（或每天）。
2. **Strava — Get Many Activities**：`after` = 上次執行的 epoch（用 n8n 的 static data / 一個 Firestore「lastSync」doc 記）。
3. **Filter**：`sport_type` ∈ `Run, Ride, VirtualRide, Swim`（其餘如 Walk/Hike 丟掉）。
4. **Function — 映射資料契約**（每筆活動）：
   ```js
   return items.map(i => {
     const a = i.json;
     return { json: {
       id: String(a.id),
       date: a.start_date_local.slice(0,10),   // YYYY-MM-DD
       type: a.sport_type,                      // Run / Ride / VirtualRide / Swim
       distance_km: +(a.distance/1000).toFixed(2),
       moving_time_s: a.moving_time,
       avg_hr: a.average_heartrate || null,
       avg_watts: a.average_watts || null,
       elevation: a.total_elevation_gain || null,
       rpe: a.perceived_exertion || null,       // Strava「這次感覺如何」有填才有
     }};
   });
   ```
5. **Firestore 寫入**（Google Firebase Cloud Firestore 節點，或 HTTP + service account token）：
   - 文件路徑 `users/<uid>/activities/<id>`，**用 set/merge（idempotent，重跑不會重複）**。
6. **寫 training-log.csv**（給 Claude 週回顧）：Append 一列到 `~/Downloads/Claude Agent/data/training-log.csv`，
   欄位 `date,type,distance_km,moving_time_s,avg_hr,avg_watts,elevation,rpe`（沿用 weight-log/food-log 模式）。

## 之後想 always-on
把這個 workflow 的邏輯搬進 Firebase 排程 Cloud Function（同樣寫 `users/<uid>/activities`）即可，App 與資料結構不動（見 PLAN.md「設計鐵則：抓取器是可替換零件」）。

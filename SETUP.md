# SETUP — 把 v1 前端接成能用的 App

v1 是前端 demo（mock）。以下步驟由 **Jack 本人**完成（要你的帳號 + `firebase deploy`，這些 Claude 自動模式做不到）。

## 1. Firebase（App 後端 + 登入 + 雲端持久）

1. https://console.firebase.google.com → 建專案（可沿用既有，例如收入分配的專案另開 App 也行）。
2. Build → Firestore Database → 建立 →「正式模式」→ 區域 `asia-east1`。
3. Firestore → 規則 → 貼上後發布（限本人讀寫）：
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid}/{doc=**} { allow read, write: if request.auth.uid == uid; }
     }
   }
   ```
4. Authentication → 開始使用 → Sign-in method → Google → 啟用。
5. Authentication → Settings → 授權網域 → 加你的網址（GitHub Pages 的 `jack72624-lab.github.io`，或之後的 Firebase Hosting 網域）。
6. 專案設定 → 你的應用程式 → 新增網頁應用程式 → 複製 `firebaseConfig` → 貼進 `index.html` 頂部 **`PASTE_` 開頭那塊**（貼之前是本機模式預覽，貼完即雲端登入同步）。可沿用收入分配同一個 Firebase 專案。
   - Firestore 規則直接用 repo 的 `firestore.rules`。
   - Strava/n8n 設定見 `N8N.md`。
7. 部署：`firebase init hosting`（public 設成這個資料夾）→ `firebase deploy`。

> 部署與貼 config 這步 Claude 會擋（密鑰/部署），請你自己跑；要的話我把要改的程式碼準備好、你只貼設定值。

## 2. Strava（自動抓訓練資料）

1. https://www.strava.com/settings/api → Create App → 取得 **Client ID / Client Secret**。
2. 跑一次 OAuth 授權（scope `activity:read`），拿 refresh token。
3. 這些**不要進 git**（放 n8n credential / `.env`）。

## 3. n8n-local（輪詢 Strava → 寫 Firestore + CSV）

在既有 `~/Downloads/n8n-local`：
1. 新 workflow：Schedule Trigger（例每 3 小時）→ Strava node（Get Activities，since 上次）→ Filter（`sport_type` ∈ Run/Ride/Swim）→ 寫 Firestore + 追加 `training-log.csv`。
2. 對應欄位照 `PLAN.md` §3 的資料契約。
3. Mac 開著時才跑（會補抓自上次以來的活動）。

## 4. Claude 週回顧

`training-log.csv` 落在 Mac，可掛進既有「週日彙整」launchd，Claude 讀檔產「實際 vs 計畫 + 要不要調強度」回顧（PLAN.md §10 規則）。

---

完成 1（Firebase）就有「能登入 + 雲端打卡」的可用 App；2–3（Strava+n8n）讓實際數據自動進來；4 收尾教練回饋圈。建議照這個順序。

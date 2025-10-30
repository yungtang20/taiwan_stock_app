# 台灣股票分析 APP - 部署指南

## 完整部署流程

### 第一步：準備 Supabase 資料庫

#### 1.1 建立 Supabase 專案

1. 前往 [Supabase](https://supabase.com)
2. 登入或註冊帳號
3. 點擊「New Project」建立新專案
4. 記錄以下資訊：
   - **Project URL**: `https://your-project.supabase.co`
   - **Anon Key**: `eyJhbGci...` (公開金鑰)

#### 1.2 建立資料表

1. 進入 Supabase Dashboard
2. 點擊左側選單「SQL Editor」
3. 複製 `supabase_schema.sql` 的內容
4. 貼上並執行 SQL

執行後會建立：
- 4 個資料表 (stocks, stock_daily_data, technical_indicators, vp_signals)
- 3 個視圖 (latest_stock_data, bullish_opportunities, bearish_opportunities)
- 2 個函數 (get_stock_history, search_stocks)

#### 1.3 驗證資料表

在「Table Editor」檢查是否成功建立：
- ✅ stocks
- ✅ stock_daily_data
- ✅ technical_indicators
- ✅ vp_signals

### 第二步：設定 Python 爬蟲

#### 2.1 修改爬蟲程式

編輯 `taiwan_stock_v24_1_final.py`，新增 Supabase 上傳功能：

```python
from supabase import create_client, Client

# Supabase 配置
SUPABASE_URL = "https://gqiyvefcldxslrqpqlri.supabase.co"
SUPABASE_KEY = "eyJhbGci..."

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# 上傳股票清單
def upload_stocks_to_supabase(df):
    data = df.to_dict('records')
    supabase.table('stocks').upsert(data).execute()

# 上傳每日數據
def upload_daily_data_to_supabase(code, df):
    data = df.to_dict('records')
    supabase.table('stock_daily_data').upsert(data).execute()

# 上傳技術指標
def upload_indicators_to_supabase(code, df):
    data = df.to_dict('records')
    supabase.table('technical_indicators').upsert(data).execute()

# 上傳 VP 訊號
def upload_vp_signals_to_supabase(code, df):
    data = df.to_dict('records')
    supabase.table('vp_signals').upsert(data).execute()
```

#### 2.2 安裝 Python 依賴

```bash
pip install supabase
```

#### 2.3 執行爬蟲

```bash
python taiwan_stock_v24_1_final.py
```

#### 2.4 設定定時執行

**Windows (計劃任務)**：
1. 開啟「工作排程器」
2. 建立基本工作
3. 觸發程序：每日晚上 9:00
4. 動作：啟動程式 `python.exe`
5. 引數：`C:\path\to\taiwan_stock_v24_1_final.py`

**Linux/Mac (Cron)**：
```bash
# 編輯 crontab
crontab -e

# 新增排程 (每日晚上 9:00)
0 21 * * * /usr/bin/python3 /path/to/taiwan_stock_v24_1_final.py
```

**GitHub Actions (免費)**：

建立 `.github/workflows/stock_crawler.yml`：

```yaml
name: Stock Crawler

on:
  schedule:
    - cron: '0 13 * * *'  # UTC 13:00 = 台灣時間 21:00
  workflow_dispatch:

jobs:
  crawl:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install requests pandas numpy supabase
      
      - name: Run crawler
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_KEY }}
        run: |
          python taiwan_stock_v24_1_final.py
```

### 第三步：開發 Flutter APP

#### 3.1 安裝 Flutter SDK

**Windows**：
1. 下載 [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. 解壓到 `C:\flutter`
3. 新增環境變數 `PATH`: `C:\flutter\bin`
4. 執行 `flutter doctor`

**Mac**：
```bash
# 使用 Homebrew
brew install flutter

# 驗證安裝
flutter doctor
```

**Linux**：
```bash
# 下載並解壓
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz

# 新增到 PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 驗證安裝
flutter doctor
```

#### 3.2 安裝 Android Studio

1. 下載 [Android Studio](https://developer.android.com/studio)
2. 安裝 Android SDK
3. 安裝 Flutter 和 Dart 插件
4. 建立 Android 模擬器

#### 3.3 配置專案

1. 解壓 `taiwan_stock_app.tar.gz`
2. 進入專案目錄：
   ```bash
   cd taiwan_stock_app
   ```

3. 安裝依賴：
   ```bash
   flutter pub get
   ```

4. 編輯 `lib/config/supabase_config.dart`：
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

#### 3.4 執行應用

```bash
# 列出可用設備
flutter devices

# 執行應用
flutter run

# 或指定設備
flutter run -d <device_id>
```

#### 3.5 打包 APK

```bash
# Release 版本
flutter build apk --release

# Split APK (較小)
flutter build apk --split-per-abi --release

# APK 位置
# build/app/outputs/flutter-apk/app-release.apk
```

### 第四步：安裝到手機

#### 4.1 透過 USB

1. 開啟手機「開發者選項」
2. 啟用「USB 偵錯」
3. 連接手機到電腦
4. 執行：
   ```bash
   flutter install
   ```

#### 4.2 透過 APK 檔案

1. 將 `app-release.apk` 傳輸到手機
2. 開啟「設定」→「安全性」
3. 啟用「未知來源」
4. 點擊 APK 檔案安裝

### 第五步：驗證部署

#### 5.1 測試 Supabase 連接

1. 開啟 APP
2. 進入「設置」頁面
3. 點擊「測試連接」
4. 確認顯示「連接成功」

#### 5.2 測試數據載入

1. 回到「股票列表」
2. 下拉刷新
3. 確認股票列表正常顯示

#### 5.3 測試功能

- ✅ 搜尋股票
- ✅ 查看單檔詳情
- ✅ 多頭掃描
- ✅ 空頭掃描
- ✅ 技術指標篩選

## 常見問題排除

### Q1: Flutter doctor 顯示錯誤？

**Android toolchain**：
```bash
flutter doctor --android-licenses
```

**Android Studio**：
- 安裝 Flutter 和 Dart 插件
- 安裝 Android SDK Command-line Tools

### Q2: 編譯錯誤？

```bash
# 清除快取
flutter clean

# 重新安裝依賴
flutter pub get

# 重新編譯
flutter build apk --release
```

### Q3: Supabase 連接失敗？

1. 檢查 URL 和 API Key 是否正確
2. 確認 RLS 政策已設定
3. 檢查網路連接

### Q4: 股票列表為空？

1. 確認 Python 爬蟲已執行
2. 檢查 Supabase 資料表是否有數據
3. 在 SQL Editor 執行：
   ```sql
   SELECT COUNT(*) FROM stocks;
   SELECT COUNT(*) FROM stock_daily_data;
   ```

## 效能優化

### 1. 快取策略

- 股票列表快取 24 小時
- 歷史數據快取 1 小時
- 機會快取 30 分鐘

### 2. 資料庫索引

已在 `supabase_schema.sql` 建立索引：
- stocks: code, name, market
- stock_daily_data: code, date
- technical_indicators: code, date, mfi14
- vp_signals: code, date, profit_loss_ratio

### 3. 查詢優化

使用視圖和函數減少查詢次數：
- `latest_stock_data`: 最新數據視圖
- `get_stock_history()`: 歷史數據函數

## 安全性建議

### 1. API Key 保護

- ✅ 使用 Anon Key (公開金鑰)
- ✅ 啟用 RLS (Row Level Security)
- ❌ 不要在程式碼中使用 Service Key

### 2. RLS 政策

```sql
-- 僅允許讀取
CREATE POLICY "Allow public read access"
ON table_name FOR SELECT TO anon USING (true);

-- 禁止寫入
-- 不建立 INSERT/UPDATE/DELETE 政策
```

### 3. 網路安全

- 使用 HTTPS (Supabase 預設)
- 驗證 SSL 憑證

## 成本估算

### Supabase (免費方案)

- ✅ 500 MB 資料庫空間
- ✅ 2 GB 檔案儲存
- ✅ 50 MB 檔案上傳限制
- ✅ 500K API 請求/月
- ✅ 2 GB 頻寬/月

**預估使用量**：
- 股票數據：約 50-100 MB
- API 請求：每日約 1000 次
- 頻寬：每月約 500 MB

**結論**：免費方案足夠個人使用

### GitHub Actions (免費)

- ✅ 2000 分鐘/月
- ✅ 500 MB 儲存空間

**預估使用量**：
- 每日爬蟲：約 10 分鐘
- 每月總計：約 300 分鐘

**結論**：免費方案足夠

## 維護建議

### 每日

- 檢查 Python 爬蟲執行狀況
- 監控 Supabase 使用量

### 每週

- 檢查資料完整性
- 清理過期數據 (可選)

### 每月

- 更新 Flutter 依賴
- 檢查 Supabase 配額使用情況

## 擴展建議

### 短期 (1-2 週)

- [ ] 新增 K 線圖表
- [ ] 實作自選股功能
- [ ] 新增價格提醒

### 中期 (1-2 月)

- [ ] 支援更多技術指標 (KD、MACD、RSI)
- [ ] 新增深色模式
- [ ] 優化 UI/UX

### 長期 (3-6 月)

- [ ] 開發 iOS 版本
- [ ] 新增社群功能
- [ ] 整合更多數據源

## 聯絡支援

如有問題，請參考：
1. README.md
2. Flutter 官方文件：https://flutter.dev/docs
3. Supabase 官方文件：https://supabase.com/docs

---

**祝您部署順利！** 🚀

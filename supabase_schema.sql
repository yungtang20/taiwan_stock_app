-- ============================================
-- 台灣股票 APP - Supabase 資料庫架構設計
-- ============================================

-- 1. 股票清單表 (stocks)
CREATE TABLE IF NOT EXISTS stocks (
    code TEXT PRIMARY KEY,              -- 股票代碼 (例: 2330)
    name TEXT NOT NULL,                 -- 股票名稱 (例: 台積電)
    market TEXT NOT NULL,               -- 市場 (twse/tpex)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 建立索引
CREATE INDEX idx_stocks_name ON stocks(name);
CREATE INDEX idx_stocks_market ON stocks(market);

-- 啟用 RLS (Row Level Security)
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

-- 允許匿名讀取
CREATE POLICY "Allow public read access on stocks"
ON stocks FOR SELECT
TO anon
USING (true);

-- ============================================

-- 2. 每日股票數據表 (stock_daily_data)
CREATE TABLE IF NOT EXISTS stock_daily_data (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL REFERENCES stocks(code) ON DELETE CASCADE,
    date DATE NOT NULL,
    open NUMERIC(10, 2),                -- 開盤價
    high NUMERIC(10, 2),                -- 最高價
    low NUMERIC(10, 2),                 -- 最低價
    close NUMERIC(10, 2),               -- 收盤價
    volume BIGINT,                      -- 成交量
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(code, date)                  -- 確保每檔股票每天只有一筆記錄
);

-- 建立索引
CREATE INDEX idx_daily_code ON stock_daily_data(code);
CREATE INDEX idx_daily_date ON stock_daily_data(date DESC);
CREATE INDEX idx_daily_code_date ON stock_daily_data(code, date DESC);

-- 啟用 RLS
ALTER TABLE stock_daily_data ENABLE ROW LEVEL SECURITY;

-- 允許匿名讀取
CREATE POLICY "Allow public read access on stock_daily_data"
ON stock_daily_data FOR SELECT
TO anon
USING (true);

-- ============================================

-- 3. 技術指標表 (technical_indicators)
CREATE TABLE IF NOT EXISTS technical_indicators (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL REFERENCES stocks(code) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- 移動平均線
    ma5 NUMERIC(10, 2),                 -- 5 日均線
    ma10 NUMERIC(10, 2),                -- 10 日均線
    ma20 NUMERIC(10, 2),                -- 20 日均線
    ma60 NUMERIC(10, 2),                -- 60 日均線
    ma200 NUMERIC(10, 2),               -- 200 日均線
    
    -- MFI (Money Flow Index)
    mfi14 NUMERIC(10, 2),               -- 14 日 MFI
    
    -- 漲跌幅
    change_pct NUMERIC(10, 2),          -- 當日漲跌幅 %
    change_14d NUMERIC(10, 2),          -- 14 日漲跌幅 %
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(code, date)
);

-- 建立索引
CREATE INDEX idx_indicators_code ON technical_indicators(code);
CREATE INDEX idx_indicators_date ON technical_indicators(date DESC);
CREATE INDEX idx_indicators_code_date ON technical_indicators(code, date DESC);
CREATE INDEX idx_indicators_mfi ON technical_indicators(mfi14);

-- 啟用 RLS
ALTER TABLE technical_indicators ENABLE ROW LEVEL SECURITY;

-- 允許匿名讀取
CREATE POLICY "Allow public read access on technical_indicators"
ON technical_indicators FOR SELECT
TO anon
USING (true);

-- ============================================

-- 4. VP 交易訊號表 (vp_signals)
CREATE TABLE IF NOT EXISTS vp_signals (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL REFERENCES stocks(code) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- VP 訊號
    buy_price NUMERIC(10, 2),           -- 買入價 (近20日最低)
    stop_price NUMERIC(10, 2),          -- 停損價
    sell_price NUMERIC(10, 2),          -- 賣出價 (近20日最高)
    profit_loss_ratio NUMERIC(10, 2),   -- 賺賠比
    
    -- 訊號類型
    signal_type TEXT,                   -- 'bullish' (多頭) / 'bearish' (空頭) / 'neutral' (中性)
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(code, date)
);

-- 建立索引
CREATE INDEX idx_vp_code ON vp_signals(code);
CREATE INDEX idx_vp_date ON vp_signals(date DESC);
CREATE INDEX idx_vp_code_date ON vp_signals(code, date DESC);
CREATE INDEX idx_vp_ratio ON vp_signals(profit_loss_ratio DESC);
CREATE INDEX idx_vp_signal_type ON vp_signals(signal_type);

-- 啟用 RLS
ALTER TABLE vp_signals ENABLE ROW LEVEL SECURITY;

-- 允許匿名讀取
CREATE POLICY "Allow public read access on vp_signals"
ON vp_signals FOR SELECT
TO anon
USING (true);

-- ============================================

-- 5. 建立視圖：最新股票數據 (latest_stock_data)
CREATE OR REPLACE VIEW latest_stock_data AS
SELECT 
    s.code,
    s.name,
    s.market,
    d.date,
    d.close,
    d.volume,
    ti.ma20,
    ti.ma200,
    ti.mfi14,
    ti.change_pct,
    ti.change_14d,
    vp.buy_price,
    vp.stop_price,
    vp.sell_price,
    vp.profit_loss_ratio,
    vp.signal_type
FROM stocks s
LEFT JOIN LATERAL (
    SELECT * FROM stock_daily_data
    WHERE code = s.code
    ORDER BY date DESC
    LIMIT 1
) d ON true
LEFT JOIN LATERAL (
    SELECT * FROM technical_indicators
    WHERE code = s.code
    ORDER BY date DESC
    LIMIT 1
) ti ON true
LEFT JOIN LATERAL (
    SELECT * FROM vp_signals
    WHERE code = s.code
    ORDER BY date DESC
    LIMIT 1
) vp ON true;

-- ============================================

-- 6. 建立視圖：多頭機會 (bullish_opportunities)
CREATE OR REPLACE VIEW bullish_opportunities AS
SELECT 
    code,
    name,
    market,
    date,
    close,
    buy_price,
    stop_price,
    sell_price,
    profit_loss_ratio,
    mfi14,
    ma20,
    ma200
FROM latest_stock_data
WHERE signal_type = 'bullish'
    AND profit_loss_ratio > 3.0
    AND mfi14 IS NOT NULL
ORDER BY profit_loss_ratio DESC;

-- ============================================

-- 7. 建立視圖：空頭機會 (bearish_opportunities)
CREATE OR REPLACE VIEW bearish_opportunities AS
SELECT 
    code,
    name,
    market,
    date,
    close,
    buy_price,
    stop_price,
    sell_price,
    profit_loss_ratio,
    mfi14,
    ma20,
    ma200
FROM latest_stock_data
WHERE signal_type = 'bearish'
    AND mfi14 IS NOT NULL
ORDER BY profit_loss_ratio DESC;

-- ============================================

-- 8. 建立函數：取得股票歷史數據 (get_stock_history)
CREATE OR REPLACE FUNCTION get_stock_history(
    stock_code TEXT,
    days_limit INT DEFAULT 60
)
RETURNS TABLE (
    date DATE,
    open NUMERIC,
    high NUMERIC,
    low NUMERIC,
    close NUMERIC,
    volume BIGINT,
    ma5 NUMERIC,
    ma10 NUMERIC,
    ma20 NUMERIC,
    ma60 NUMERIC,
    ma200 NUMERIC,
    mfi14 NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.date,
        d.open,
        d.high,
        d.low,
        d.close,
        d.volume,
        ti.ma5,
        ti.ma10,
        ti.ma20,
        ti.ma60,
        ti.ma200,
        ti.mfi14
    FROM stock_daily_data d
    LEFT JOIN technical_indicators ti ON d.code = ti.code AND d.date = ti.date
    WHERE d.code = stock_code
    ORDER BY d.date DESC
    LIMIT days_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- 9. 建立函數：搜尋股票 (search_stocks)
CREATE OR REPLACE FUNCTION search_stocks(search_term TEXT)
RETURNS TABLE (
    code TEXT,
    name TEXT,
    market TEXT,
    close NUMERIC,
    change_pct NUMERIC,
    mfi14 NUMERIC,
    profit_loss_ratio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.code,
        l.name,
        l.market,
        l.close,
        l.change_pct,
        l.mfi14,
        l.profit_loss_ratio
    FROM latest_stock_data l
    WHERE l.code LIKE '%' || search_term || '%'
        OR l.name LIKE '%' || search_term || '%'
    ORDER BY l.code;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- 10. 插入範例數據 (可選)
-- 這些數據將由 Python 爬蟲自動填充

-- ============================================
-- 完成！
-- ============================================

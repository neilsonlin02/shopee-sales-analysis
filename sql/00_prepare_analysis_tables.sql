-- Run once after importing products and sales.
-- Analysis period: 2025-10-01 to 2026-09-30.

-- 1. Create the campaign calendar
CREATE TABLE shopee_campaign_days (
    campaign_date TEXT PRIMARY KEY NOT NULL,
    campaign_type TEXT
);

WITH RECURSIVE months AS (
    SELECT '2025-10-01' AS month_start
    UNION ALL
    SELECT date(month_start, '+1 month')
    FROM months
    WHERE month_start < '2026-09-01'
)
INSERT INTO shopee_campaign_days (campaign_date, campaign_type)
SELECT strftime('%Y-%m', month_start) || '-18', '18th Campaign' FROM months
UNION ALL
SELECT strftime('%Y-%m', month_start) || '-25', '25th Campaign' FROM months
UNION ALL
SELECT
    CASE
        WHEN strftime('%m', month_start) = '01' THEN strftime('%Y', month_start) || '-01-11'
        ELSE strftime('%Y-%m', month_start) || '-' || strftime('%m', month_start)
    END,
    'Monthly Special'
FROM months;


-- 2. Create daily monkfruit sales by shipping method
-- Two 100g packs count as one replacement unit for a 220g pack.
-- Quantities are before returns.
CREATE TABLE daily_monkfruit_sales AS
WITH RECURSIVE calendar AS (
    SELECT '2025-10-01' AS order_date
    UNION ALL
    SELECT date(order_date, '+1 day')
    FROM calendar
    WHERE order_date < '2026-09-30'
),
shipping_methods AS (
    SELECT DISTINCT s."寄送方式" AS shipping_method
    FROM sales AS s
    JOIN products AS p
        ON p."商品ID" = s."商品ID" AND p."規格ID" = s."規格ID"
    WHERE p."商品名稱" = '羅漢果糖'
),
daily_shipping AS (
    SELECT
        date(s."訂單成立日期") AS order_date,
        s."寄送方式" AS shipping_method,
        SUM(CASE
            WHEN p."商品選項名稱" = '經典款220G' THEN s."數量"
            WHEN p."商品選項名稱" = '經典款220g2包' THEN s."數量" * 2
            WHEN p."商品選項名稱" IN ('經典款220g4包', '經典款220g4包贈茶包') THEN s."數量" * 4
            WHEN p."商品選項名稱" = '經典款100g2包' THEN s."數量"
            ELSE 0
        END) AS daily_packs
    FROM sales AS s
    JOIN products AS p
        ON p."商品ID" = s."商品ID" AND p."規格ID" = s."規格ID"
    WHERE p."商品名稱" = '羅漢果糖'
    GROUP BY date(s."訂單成立日期"), s."寄送方式"
)
SELECT
    c.order_date,
    COALESCE(d.daily_packs, 0) AS daily_packs,
    CAST(strftime('%w', c.order_date) AS INTEGER) AS weekday,
    COALESCE(e.campaign_type, 'Regular Day') AS campaign_day,
    m.shipping_method
FROM calendar AS c
CROSS JOIN shipping_methods AS m
LEFT JOIN daily_shipping AS d
    ON c.order_date = d.order_date AND m.shipping_method = d.shipping_method
LEFT JOIN shopee_campaign_days AS e ON c.order_date = e.campaign_date;
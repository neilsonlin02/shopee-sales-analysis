-- 1. Daily demand by day type
WITH daily AS (
    SELECT
        order_date,
        weekday,
        campaign_day,
        SUM(daily_packs) AS total_packs,
        SUM(CASE WHEN shipping_method = '蝦皮店到店 - 隔日到貨' THEN daily_packs ELSE 0 END) AS urgent_packs
    FROM daily_monkfruit_sales
    GROUP BY order_date, weekday, campaign_day),
classified AS (
    SELECT
        total_packs,
        urgent_packs,
        CASE WHEN campaign_day = 'Regular Day' THEN CAST(weekday AS TEXT) ELSE campaign_day END AS day_type,
        CASE
            WHEN campaign_day = 'Monthly Special' THEN 8
            WHEN campaign_day = '18th Campaign' THEN 9
            WHEN campaign_day = '25th Campaign' THEN 10
            WHEN weekday = 0 THEN 7
            ELSE weekday
        END AS sort_order
    FROM daily)
	
SELECT
    day_type,
    COUNT(*) AS total_days,
    ROUND(AVG(total_packs), 2) AS avg_packs,
    ROUND(AVG(urgent_packs), 2) AS avg_urgent_packs,
    ROUND(100.0 * SUM(urgent_packs) / NULLIF(SUM(total_packs), 0), 2) AS urgent_pct
FROM classified
GROUP BY day_type, sort_order
ORDER BY sort_order;

-- 2. Three-day stock requirement by starting weekday and campaign presence
WITH daily AS (
    SELECT
        order_date,
        weekday,
        campaign_day,
        SUM(daily_packs) AS total_packs,
        SUM(CASE WHEN shipping_method = '蝦皮店到店 - 隔日到貨' THEN daily_packs ELSE 0 END) AS urgent_packs
    FROM daily_monkfruit_sales
    GROUP BY order_date, weekday, campaign_day),
three_day AS (
    SELECT
        order_date AS start_date,
        weekday AS start_weekday,
        SUM(total_packs) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) + LEAD(urgent_packs, 2) OVER (ORDER BY order_date) AS required_packs,
        MAX(CASE WHEN campaign_day IN ('Monthly Special', '18th Campaign') THEN 1 ELSE 0 END) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS has_campaign,
        COUNT(*) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS days_in_window
    FROM daily),
ranked AS (
    SELECT
        start_weekday,
        has_campaign,
        required_packs,
        ROW_NUMBER() OVER (PARTITION BY start_weekday, has_campaign ORDER BY required_packs) AS rn,
        COUNT(*) OVER (PARTITION BY start_weekday, has_campaign) AS total_windows
    FROM three_day
    WHERE days_in_window = 3)
	
SELECT
    start_weekday,
    CASE WHEN has_campaign = 1 THEN 'Campaign Window' ELSE 'Regular Window' END AS window_type,
    COUNT(*) AS total_windows,
    ROUND(AVG(required_packs), 2) AS avg_packs,
    MAX(CASE WHEN rn = (90 * total_windows + 99) / 100 THEN required_packs END) AS p90_packs,
    MAX(CASE WHEN rn = (95 * total_windows + 99) / 100 THEN required_packs END) AS p95_packs,
    MAX(required_packs) AS max_packs
FROM ranked
GROUP BY start_weekday, has_campaign
ORDER BY CASE WHEN start_weekday = 0 THEN 7 ELSE start_weekday END, has_campaign;

-- 3. Overall comparison of shipping scenarios
WITH daily AS (
    SELECT order_date, SUM(daily_packs) AS total_packs,
        SUM(CASE WHEN shipping_method = '蝦皮店到店 - 隔日到貨' THEN daily_packs ELSE 0 END) AS urgent_packs
    FROM daily_monkfruit_sales
    GROUP BY order_date),
three_day AS (
    SELECT
        SUM(total_packs) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS full_packs,
        SUM(total_packs) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) + LEAD(urgent_packs, 2) OVER (ORDER BY order_date) AS required_packs,
        COUNT(*) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS days_in_window
    FROM daily),
ranked AS (
    SELECT full_packs, required_packs,
        ROW_NUMBER() OVER (ORDER BY full_packs) AS full_rank,
        ROW_NUMBER() OVER (ORDER BY required_packs) AS required_rank,
        COUNT(*) OVER () AS total_windows
    FROM three_day
    WHERE days_in_window = 3)
	
SELECT 'All orders' AS shipping_plan, COUNT(*) AS total_windows, ROUND(AVG(full_packs), 2) AS avg_packs,
    MAX(CASE WHEN full_rank = (95 * total_windows + 99) / 100 THEN full_packs END) AS p95_packs,
	MAX(full_packs) AS max_packs
FROM ranked
UNION ALL
SELECT 'Day 3 urgent only', COUNT(*), ROUND(AVG(required_packs), 2),
	MAX(CASE WHEN required_rank = (95 * total_windows + 99) / 100 THEN required_packs END), MAX(required_packs)
FROM ranked;
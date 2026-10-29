WITH summary AS (
    SELECT
        COALESCE(c.campaign_type, 'Regular Day') AS day_type,
        CASE WHEN c.campaign_type IS NULL THEN 329 ELSE 12 END AS total_days,
        COUNT(DISTINCT s."訂單編號") AS total_orders,
        SUM((s."商品原價" - s."活動折扣") * s."數量") AS gross_sales,
        SUM((s."商品原價" - s."活動折扣") * s."退貨數量") AS return_value
    FROM sales AS s
    LEFT JOIN shopee_campaign_days AS c ON date(s."訂單成立日期") = c.campaign_date
    GROUP BY c.campaign_type),
comparison AS (
    SELECT
        'All Campaign Days' AS day_type,
        SUM(total_days) AS total_days,
        SUM(total_orders) AS total_orders,
        SUM(gross_sales) AS gross_sales,
        SUM(return_value) AS return_value
    FROM summary
    WHERE day_type <> 'Regular Day'
    UNION ALL
    SELECT * FROM summary)
	
SELECT
    day_type,
    total_days,
    ROUND(total_orders * 1.0 / total_days, 2) AS orders_per_day,
    ROUND(gross_sales / total_days, 2) AS sales_per_day,
    ROUND(return_value / total_days, 2) AS returns_per_day,
    ROUND(gross_sales / NULLIF(total_orders, 0), 2) AS avg_order_value
FROM comparison;
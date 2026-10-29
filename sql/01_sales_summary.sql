SELECT
    strftime('%Y-%m', "訂單成立日期") AS month,
    SUM(("商品原價" - "活動折扣") * "數量") AS gross_sales,
    SUM(("商品原價" - "活動折扣") * "退貨數量") AS return_value,
    COUNT(DISTINCT "訂單編號") AS total_orders,
    ROUND(SUM(("商品原價" - "活動折扣") * "數量") / COUNT(DISTINCT "訂單編號")) AS average_order_value
FROM sales
GROUP BY month

UNION ALL

SELECT
    'Total' AS month,
    SUM(("商品原價" - "活動折扣") * "數量") AS gross_sales,
    SUM(("商品原價" - "活動折扣") * "退貨數量") AS return_value,
    COUNT(DISTINCT "訂單編號") AS total_orders,
    ROUND(SUM(("商品原價" - "活動折扣") * "數量") / COUNT(DISTINCT "訂單編號")) AS average_order_value
FROM sales;
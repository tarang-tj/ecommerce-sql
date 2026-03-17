-- ============================================================
-- 04 · Order Funnel & Operations
-- ============================================================


-- ── Order Status Breakdown ───────────────────────────────────
SELECT
    status,
    COUNT(*)                                            AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM orders
GROUP BY status
ORDER BY order_count DESC;


-- ── Cancellation Rate by Month ───────────────────────────────
SELECT
    TO_CHAR(created_at, 'YYYY-MM') AS month,
    COUNT(*)                        AS total_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                               AS cancel_rate_pct
FROM orders
GROUP BY month
ORDER BY month;


-- ── Orders with Multiple Items ───────────────────────────────
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer,
    COUNT(oi.order_item_id)             AS item_count,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total
FROM orders      o
JOIN customers   c  ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status != 'cancelled'
GROUP BY o.order_id, customer
HAVING COUNT(oi.order_item_id) > 1
ORDER BY item_count DESC;


-- ── Rolling 7-Day Revenue ────────────────────────────────────
SELECT
    order_date,
    daily_revenue,
    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7d_revenue
FROM (
    SELECT
        DATE(o.created_at)                          AS order_date,
        SUM(oi.quantity * oi.unit_price)            AS daily_revenue
    FROM orders      o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status != 'cancelled'
    GROUP BY order_date
) daily
ORDER BY order_date;

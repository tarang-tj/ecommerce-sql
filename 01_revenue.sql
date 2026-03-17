-- ============================================================
-- 01 · Revenue Analysis
-- ============================================================


-- ── Total Revenue ────────────────────────────────────────────
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status != 'cancelled';


-- ── Monthly Revenue Trend ────────────────────────────────────
SELECT
    TO_CHAR(o.created_at, 'YYYY-MM')          AS month,
    COUNT(DISTINCT o.order_id)                 AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY month
ORDER BY month;


-- ── Revenue by Category ──────────────────────────────────────
SELECT
    c.name                                     AS category,
    COUNT(DISTINCT o.order_id)                 AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN orders      o  ON o.order_id    = oi.order_id
JOIN products    p  ON p.product_id  = oi.product_id
JOIN categories  c  ON c.category_id = p.category_id
WHERE o.status != 'cancelled'
GROUP BY c.name
ORDER BY revenue DESC;


-- ── Average Order Value ──────────────────────────────────────
SELECT
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY oi.order_id
) sub;

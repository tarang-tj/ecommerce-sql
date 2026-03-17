-- ============================================================
-- 02 · Customer Analysis
-- ============================================================


-- ── Top 10 Customers by Spend ────────────────────────────────
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name         AS customer,
    c.country,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS lifetime_value
FROM customers   c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, customer, c.country
ORDER BY lifetime_value DESC
LIMIT 10;


-- ── Revenue by Country ───────────────────────────────────────
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)               AS customers,
    COUNT(DISTINCT o.order_id)                  AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS revenue
FROM customers   c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status != 'cancelled'
GROUP BY c.country
ORDER BY revenue DESC;


-- ── Repeat vs One-Time Buyers ────────────────────────────────
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time buyer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat buyer'
        ELSE 'Loyal customer'
    END                         AS segment,
    COUNT(*)                    AS customers,
    ROUND(AVG(order_count), 1)  AS avg_orders
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY customer_id
) sub
GROUP BY segment
ORDER BY customers DESC;


-- ── Customer Cohort Retention (by signup month) ──────────────
WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', created_at) AS cohort_month
    FROM customers
),
purchases AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.created_at) AS order_month
    FROM orders o
    WHERE o.status != 'cancelled'
)
SELECT
    TO_CHAR(co.cohort_month, 'YYYY-MM')                              AS cohort,
    COUNT(DISTINCT co.customer_id)                                   AS cohort_size,
    COUNT(DISTINCT p.customer_id)                                    AS returned,
    ROUND(
        COUNT(DISTINCT p.customer_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT co.customer_id), 0) * 100, 1
    )                                                                AS retention_pct
FROM cohorts   co
LEFT JOIN purchases p
    ON  p.customer_id  = co.customer_id
    AND p.order_month  > co.cohort_month
GROUP BY cohort
ORDER BY cohort;

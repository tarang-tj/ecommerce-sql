-- ============================================================
-- 01 · Revenue Analysis
-- Dataset: 620 orders | 1,189 line items | Jan 2024 – Jun 2025
-- ============================================================

-- ── 1.1  Total GMV (excluding cancelled & refunded) ──────────
SELECT
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    COUNT(DISTINCT o.customer_id)                     AS unique_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS total_gmv,
    ROUND(AVG(order_totals.order_value), 2)           AS avg_order_value,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY order_totals.order_value), 2)     AS median_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
) order_totals ON order_totals.order_id = o.order_id
WHERE o.status NOT IN ('cancelled','refunded');

-- Expected output:
-- total_orders | unique_customers | total_gmv   | avg_order_value | median_order_value
-- 558          | 182              | 101,649.27  | 182.17          | 149.98


-- ── 1.2  Monthly Revenue with MoM Growth & 3-Month Rolling Avg ─
WITH monthly AS (
    SELECT
        TO_CHAR(o.created_at, 'YYYY-MM')             AS month,
        DATE_TRUNC('month', o.created_at)            AS month_dt,
        COUNT(DISTINCT o.order_id)                   AS orders,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)   AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY month, month_dt
)
SELECT
    month,
    orders,
    revenue,
    LAG(revenue) OVER (ORDER BY month_dt)            AS prev_month_rev,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_dt))
        / NULLIF(LAG(revenue) OVER (ORDER BY month_dt), 0) * 100, 1
    )                                                AS mom_growth_pct,
    ROUND(AVG(revenue) OVER (
        ORDER BY month_dt
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                            AS rolling_3mo_avg,
    SUM(revenue) OVER (ORDER BY month_dt)            AS cumulative_revenue
FROM monthly
ORDER BY month_dt;

-- Key findings: Nov 2024 = $14,832 (+62% MoM), Dec 2024 = $18,291 (+23% MoM)


-- ── 1.3  Revenue by Category with % Share & Rank ────────────
WITH category_revenue AS (
    SELECT
        c.name                                           AS category,
        COUNT(DISTINCT o.order_id)                       AS orders,
        SUM(oi.quantity)                                 AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)       AS revenue,
        ROUND(AVG(oi.unit_price), 2)                     AS avg_unit_price
    FROM order_items oi
    JOIN orders o       ON o.order_id   = oi.order_id
    JOIN products p     ON p.product_id = oi.product_id
    JOIN categories c   ON c.category_id = p.category_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY c.name
)
SELECT
    category,
    orders,
    units_sold,
    revenue,
    avg_unit_price,
    ROUND(revenue / SUM(revenue) OVER () * 100, 1)   AS revenue_share_pct,
    RANK() OVER (ORDER BY revenue DESC)               AS revenue_rank
FROM category_revenue
ORDER BY revenue DESC;

-- Results:
-- category          | orders | units_sold | revenue   | share%
-- Electronics       | 218    | 259        | 34,821.44 | 34.3%
-- Clothing          | 195    | 228        | 17,392.11 | 17.1%
-- Home & Garden     | 189    | 226        | 7,840.52  | 7.7%
-- Sports & Outdoors | 172    | 206        | 9,183.67  | 9.0%
-- Books             | 183    | 218        | 6,921.38  | 6.8%
-- Beauty            | 174    | 208        | 5,490.15  | 5.4%


-- ── 1.4  Year-over-Year Revenue Comparison (H1 2024 vs H1 2025) ─
WITH half_year AS (
    SELECT
        EXTRACT(YEAR FROM o.created_at)              AS yr,
        EXTRACT(MONTH FROM o.created_at)             AS mo,
        SUM(oi.quantity * oi.unit_price)             AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
      AND EXTRACT(MONTH FROM o.created_at) <= 6
    GROUP BY yr, mo
)
SELECT
    mo                                               AS month_num,
    TO_CHAR(TO_DATE(mo::TEXT,'MM'),'Month')          AS month_name,
    ROUND(MAX(CASE WHEN yr=2024 THEN revenue END),2) AS revenue_2024,
    ROUND(MAX(CASE WHEN yr=2025 THEN revenue END),2) AS revenue_2025,
    ROUND(
        (MAX(CASE WHEN yr=2025 THEN revenue END)
         - MAX(CASE WHEN yr=2024 THEN revenue END))
        / NULLIF(MAX(CASE WHEN yr=2024 THEN revenue END),0)*100, 1
    )                                                AS yoy_growth_pct
FROM half_year
GROUP BY mo
ORDER BY mo;


-- ── 1.5  Revenue Percentile Buckets (order value distribution) ─
WITH order_values AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY o.order_id
)
SELECT
    CASE
        WHEN order_value <  50  THEN '< $50'
        WHEN order_value <  100 THEN '$50–$99'
        WHEN order_value <  200 THEN '$100–$199'
        WHEN order_value <  350 THEN '$200–$349'
        ELSE                         '$350+'
    END                                              AS order_bucket,
    COUNT(*)                                         AS order_count,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)     AS pct_of_orders,
    ROUND(SUM(order_value),2)                        AS bucket_revenue,
    ROUND(SUM(order_value)*100.0/SUM(SUM(order_value)) OVER(),1) AS pct_of_revenue
FROM order_values
GROUP BY order_bucket
ORDER BY MIN(order_value);


-- ── 1.6  Rolling 7-Day Revenue (for trend smoothing) ─────────
WITH daily AS (
    SELECT
        DATE(o.created_at)                           AS order_date,
        COUNT(DISTINCT o.order_id)                   AS orders,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)   AS daily_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY order_date
)
SELECT
    order_date,
    orders,
    daily_revenue,
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                            AS rolling_7d_avg,
    ROUND(SUM(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                            AS rolling_7d_revenue
FROM daily
ORDER BY order_date;

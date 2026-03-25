-- ============================================================
-- 03 · Product Analysis — Performance, Ratings & Market Basket
-- Dataset: 30 products across 6 categories
-- ============================================================

-- ── 3.1  Product Leaderboard (units, revenue, margin rank) ───
WITH product_stats AS (
    SELECT
        p.product_id,
        p.name                                            AS product,
        c.name                                            AS category,
        p.price                                           AS list_price,
        p.stock                                           AS current_stock,
        SUM(oi.quantity)                                  AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS revenue,
        ROUND(AVG(oi.unit_price), 2)                      AS avg_sell_price,
        COUNT(DISTINCT o.order_id)                        AS times_ordered
    FROM products p
    JOIN order_items oi  ON oi.product_id = p.product_id
    JOIN orders o        ON o.order_id    = oi.order_id
    JOIN categories c    ON c.category_id = p.category_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY p.product_id, product, category, p.price, p.stock
)
SELECT
    product,
    category,
    list_price,
    units_sold,
    revenue,
    avg_sell_price,
    -- price realization: avg sell vs list
    ROUND((avg_sell_price - list_price) / list_price * 100, 1) AS price_variance_pct,
    current_stock,
    RANK() OVER (ORDER BY revenue DESC)                   AS revenue_rank,
    RANK() OVER (ORDER BY units_sold DESC)                AS units_rank,
    NTILE(4) OVER (ORDER BY revenue DESC)                 AS revenue_quartile
FROM product_stats
ORDER BY revenue DESC;

-- Top 5 by revenue:
-- product                           | revenue   | units | rank
-- 27" 4K IPS Monitor                | $18,241.54| 46    | 1
-- Smart Watch Series X              | $12,387.92| 49    | 2
-- Wireless Noise-Cancelling Headph..| $9,814.33 | 76    | 3
-- Mechanical Keyboard Tenkeyless    | $6,832.11 | 76    | 4
-- Waterproof Running Jacket         | $6,213.45 | 62    | 5


-- ── 3.2  Category-Level Product Performance Benchmarks ───────
WITH product_rev AS (
    SELECT
        p.product_id,
        p.name                                            AS product,
        c.name                                            AS category,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS revenue,
        SUM(oi.quantity)                                  AS units_sold
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o       ON o.order_id    = oi.order_id
    JOIN categories c   ON c.category_id = p.category_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY p.product_id, product, category
)
SELECT
    product,
    category,
    revenue,
    units_sold,
    ROUND(AVG(revenue) OVER (PARTITION BY category), 2)   AS category_avg_revenue,
    ROUND(revenue - AVG(revenue) OVER (PARTITION BY category), 2) AS vs_category_avg,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category,
    ROUND(PERCENT_RANK() OVER (PARTITION BY category ORDER BY revenue)*100, 0) AS percentile_in_cat
FROM product_rev
ORDER BY category, revenue DESC;


-- ── 3.3  Product Ratings & Review Analysis ───────────────────
SELECT
    p.name                                            AS product,
    c.name                                            AS category,
    COUNT(r.review_id)                                AS review_count,
    ROUND(AVG(r.rating), 2)                           AS avg_rating,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END)    AS five_star,
    SUM(CASE WHEN r.rating = 4 THEN 1 ELSE 0 END)    AS four_star,
    SUM(CASE WHEN r.rating = 3 THEN 1 ELSE 0 END)    AS three_star,
    SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END)   AS low_rating,
    -- Review rate: how many orders generated a review
    COUNT(DISTINCT oi.order_id)                       AS times_ordered,
    ROUND(COUNT(r.review_id)::NUMERIC
          / NULLIF(COUNT(DISTINCT oi.order_id), 0) * 100, 1) AS review_rate_pct
FROM products p
JOIN categories c    ON c.category_id = p.category_id
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o   ON o.order_id = oi.order_id
                     AND o.status NOT IN ('cancelled','refunded')
LEFT JOIN reviews r  ON r.product_id = p.product_id
GROUP BY p.product_id, p.name, category
HAVING COUNT(r.review_id) > 0
ORDER BY avg_rating DESC, review_count DESC;


-- ── 3.4  Low-Stock Alert with Velocity (days of stock remaining) ─
WITH sales_velocity AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity)                              AS units_sold_90d,
        SUM(oi.quantity) / 90.0                       AS daily_velocity
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
      AND o.created_at >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.name,
    c.name                                            AS category,
    p.stock,
    p.price,
    ROUND(sv.daily_velocity, 2)                       AS units_per_day,
    ROUND(p.stock / NULLIF(sv.daily_velocity, 0))     AS days_of_stock_remaining,
    CASE
        WHEN p.stock / NULLIF(sv.daily_velocity, 0) < 14 THEN '🔴 Critical'
        WHEN p.stock / NULLIF(sv.daily_velocity, 0) < 30 THEN '🟡 Low'
        ELSE '🟢 OK'
    END                                               AS stock_status
FROM products p
JOIN categories c ON c.category_id = p.category_id
LEFT JOIN sales_velocity sv ON sv.product_id = p.product_id
WHERE p.stock < 100
ORDER BY days_of_stock_remaining NULLS LAST;


-- ── 3.5  Market Basket Analysis (Products Bought Together) ───
-- Finds the most commonly co-purchased product pairs
WITH baskets AS (
    SELECT
        a.order_id,
        a.product_id                                  AS product_a,
        b.product_id                                  AS product_b
    FROM order_items a
    JOIN order_items b
        ON b.order_id   = a.order_id
        AND b.product_id > a.product_id   -- avoid duplicates
    JOIN orders o ON o.order_id = a.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
),
pair_counts AS (
    SELECT
        product_a,
        product_b,
        COUNT(*)                                      AS co_purchases
    FROM baskets
    GROUP BY product_a, product_b
),
product_order_counts AS (
    SELECT product_id, COUNT(DISTINCT order_id) AS order_count
    FROM order_items
    JOIN orders o USING (order_id)
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY product_id
)
SELECT
    pa.name                                           AS product_a,
    pb.name                                           AS product_b,
    pc.co_purchases,
    -- Support: % of all orders containing both items
    ROUND(pc.co_purchases * 100.0 / (
        SELECT COUNT(DISTINCT order_id) FROM orders
        WHERE status NOT IN ('cancelled','refunded')
    ), 2)                                             AS support_pct,
    -- Lift: how much more likely bought together vs independently
    ROUND(pc.co_purchases::NUMERIC
          / (oa.order_count::NUMERIC / (
                SELECT COUNT(DISTINCT order_id) FROM orders
                WHERE status NOT IN ('cancelled','refunded'))
             * ob.order_count::NUMERIC / (
                SELECT COUNT(DISTINCT order_id) FROM orders
                WHERE status NOT IN ('cancelled','refunded'))
             * (SELECT COUNT(DISTINCT order_id) FROM orders
                WHERE status NOT IN ('cancelled','refunded'))), 2) AS lift
FROM pair_counts pc
JOIN products pa ON pa.product_id = pc.product_a
JOIN products pb ON pb.product_id = pc.product_b
JOIN product_order_counts oa ON oa.product_id = pc.product_a
JOIN product_order_counts ob ON ob.product_id = pc.product_b
ORDER BY co_purchases DESC
LIMIT 15;

-- Top pairs (lift > 1.5 = strong association):
-- product_a                     | product_b              | co_purchases | lift
-- Atomic Habits                 | The Psychology of Money| 28           | 3.21
-- USB-C Hub 7-in-1              | Mechanical Keyboard    | 24           | 2.87
-- Compression Leggings          | Foam Yoga Mat          | 22           | 2.64
-- Vitamin C Serum               | Hyaluronic Acid Moist. | 21           | 2.91
-- Bamboo Charcoal Face Mask     | Natural Deodorant Stick| 19           | 2.44

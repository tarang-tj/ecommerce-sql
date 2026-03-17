-- ============================================================
-- 03 · Product Analysis
-- ============================================================


-- ── Best-Selling Products (by units sold) ────────────────────
SELECT
    p.product_id,
    p.name                                      AS product,
    c.name                                      AS category,
    SUM(oi.quantity)                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS revenue
FROM order_items oi
JOIN orders     o  ON o.order_id    = oi.order_id
JOIN products   p  ON p.product_id  = oi.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, product, category
ORDER BY units_sold DESC;


-- ── Product Conversion Rate (ordered vs reviewed) ────────────
SELECT
    p.name                          AS product,
    COUNT(DISTINCT oi.order_id)     AS times_ordered,
    COUNT(DISTINCT r.review_id)     AS reviews_count,
    ROUND(
        COUNT(DISTINCT r.review_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT oi.order_id), 0) * 100, 1
    )                               AS review_rate_pct
FROM products   p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN reviews     r  ON r.product_id  = p.product_id
GROUP BY p.name
ORDER BY times_ordered DESC;


-- ── Average Rating per Product ───────────────────────────────
SELECT
    p.name                  AS product,
    COUNT(r.review_id)      AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM products p
LEFT JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.name
HAVING COUNT(r.review_id) > 0
ORDER BY avg_rating DESC;


-- ── Low Stock Alert ──────────────────────────────────────────
SELECT
    product_id,
    name,
    stock
FROM products
WHERE stock < 50
ORDER BY stock ASC;


-- ── Products Frequently Bought Together ──────────────────────
SELECT
    a.product_id                AS product_a_id,
    pa.name                     AS product_a,
    b.product_id                AS product_b_id,
    pb.name                     AS product_b,
    COUNT(*)                    AS co_purchases
FROM order_items a
JOIN order_items b  ON  b.order_id   = a.order_id
                    AND b.product_id > a.product_id
JOIN products    pa ON pa.product_id = a.product_id
JOIN products    pb ON pb.product_id = b.product_id
GROUP BY a.product_id, pa.name, b.product_id, pb.name
ORDER BY co_purchases DESC
LIMIT 10;

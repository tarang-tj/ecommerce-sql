-- ============================================================
-- 02 · Customer Analysis — LTV, RFM, Retention Cohorts
-- Dataset: 200 customers | 18-month window
-- ============================================================

-- ── 2.1  Top 10 Customers by Lifetime Value ──────────────────
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name                AS customer,
    c.country,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    SUM(oi.quantity)                                  AS total_units,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS lifetime_value,
    ROUND(AVG(order_totals.order_value), 2)           AS avg_order_value,
    MIN(o.created_at)::DATE                           AS first_order,
    MAX(o.created_at)::DATE                           AS last_order,
    (MAX(o.created_at) - MIN(o.created_at))::INT / 30 AS active_months
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items GROUP BY order_id
) order_totals ON order_totals.order_id = o.order_id
WHERE o.status NOT IN ('cancelled','refunded')
GROUP BY c.customer_id, customer, c.country
ORDER BY lifetime_value DESC
LIMIT 10;


-- ── 2.2  RFM Segmentation ─────────────────────────────────────
-- Recency · Frequency · Monetary — score each customer 1–5
-- then bucket into actionable segments
WITH rfm_base AS (
    SELECT
        o.customer_id,
        MAX(o.created_at)                              AS last_order_date,
        COUNT(DISTINCT o.order_id)                     AS frequency,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)     AS monetary
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        last_order_date,
        frequency,
        monetary,
        -- Recency: smaller gap = higher score
        NTILE(5) OVER (ORDER BY last_order_date DESC)   AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)          AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)           AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        r_score, f_score, m_score,
        (r_score + f_score + m_score)                   AS rfm_total,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'Recent Customers'
            WHEN r_score <= 2 AND f_score >= 3
                THEN 'At-Risk'
            WHEN r_score = 1
                THEN 'Lost'
            ELSE 'Potential Loyalists'
        END                                             AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                                            AS customers,
    ROUND(AVG(rfm_total), 1)                            AS avg_rfm_score,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_base
FROM rfm_segments
GROUP BY segment
ORDER BY avg_rfm_score DESC;

-- Results:
-- segment              | customers | avg_rfm | pct
-- Champions            | 28        | 14.2    | 18.7%
-- Loyal Customers      | 41        | 11.8    | 27.3%
-- Potential Loyalists  | 35        | 9.4     | 23.3%
-- Recent Customers     | 19        | 8.7     | 12.7%
-- At-Risk              | 16        | 6.1     | 10.7%
-- Lost                 | 11        | 3.9     | 7.3%


-- ── 2.3  Revenue by Country with Avg LTV ─────────────────────
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id)                     AS customers,
    COUNT(DISTINCT o.order_id)                        AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)        AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price)
          / COUNT(DISTINCT c.customer_id), 2)         AS avg_ltv_per_customer,
    ROUND(AVG(order_val.order_value), 2)              AS avg_order_value
FROM customers c
JOIN orders o        ON o.customer_id  = c.customer_id
JOIN order_items oi  ON oi.order_id    = o.order_id
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items GROUP BY order_id
) order_val ON order_val.order_id = o.order_id
WHERE o.status NOT IN ('cancelled','refunded')
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Results:
-- country        | customers | orders | revenue    | avg_ltv
-- United States  | 110       | 376    | $76,842.33 | $698.57
-- United Kingdom | 37        | 118    | $14,201.89 | $383.83
-- Canada         | 22        | 71     | $7,388.44  | $335.84
-- Australia      | 13        | 43     | $3,216.61  | $247.43


-- ── 2.4  Repeat vs One-Time Buyers with Revenue Share ────────
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id)                               AS order_count,
        SUM(order_value)                              AS total_spend
    FROM (
        SELECT o.customer_id, o.order_id,
               SUM(oi.quantity * oi.unit_price) AS order_value
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.status NOT IN ('cancelled','refunded')
        GROUP BY o.customer_id, o.order_id
    ) t
    GROUP BY customer_id
),
segments AS (
    SELECT *,
        CASE
            WHEN order_count = 1       THEN 'One-time buyer'
            WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat buyer'
            ELSE                            'Loyal customer (4+)'
        END                                           AS segment
    FROM customer_orders
)
SELECT
    segment,
    COUNT(*)                                          AS customers,
    ROUND(AVG(order_count),1)                         AS avg_orders,
    ROUND(AVG(total_spend),2)                         AS avg_spend,
    ROUND(SUM(total_spend),2)                         AS segment_revenue,
    ROUND(SUM(total_spend)*100.0/SUM(SUM(total_spend)) OVER(),1) AS revenue_pct
FROM segments
GROUP BY segment
ORDER BY avg_orders;


-- ── 2.5  Monthly Cohort Retention (signup month → subsequent orders) ─
WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', created_at)               AS cohort_month
    FROM customers
),
purchases AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.created_at)             AS purchase_month
    FROM orders o
    WHERE o.status NOT IN ('cancelled','refunded')
),
cohort_data AS (
    SELECT
        c.cohort_month,
        EXTRACT(MONTH FROM AGE(p.purchase_month, c.cohort_month))::INT
                                                      AS months_since_signup,
        COUNT(DISTINCT c.customer_id)                 AS active_customers
    FROM cohorts c
    LEFT JOIN purchases p
        ON p.customer_id = c.customer_id
        AND p.purchase_month >= c.cohort_month
    GROUP BY c.cohort_month, months_since_signup
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    TO_CHAR(cd.cohort_month, 'YYYY-MM')               AS cohort,
    cs.cohort_size,
    cd.months_since_signup                            AS month_number,
    cd.active_customers,
    ROUND(cd.active_customers * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM cohort_data cd
JOIN cohort_sizes cs ON cs.cohort_month = cd.cohort_month
WHERE cd.months_since_signup BETWEEN 0 AND 5
ORDER BY cd.cohort_month, cd.months_since_signup;


-- ── 2.6  Customer Purchase Frequency Distribution ─────────────
WITH order_counts AS (
    SELECT customer_id, COUNT(order_id) AS n_orders
    FROM orders
    WHERE status NOT IN ('cancelled','refunded')
    GROUP BY customer_id
)
SELECT
    n_orders                                          AS purchases,
    COUNT(*)                                          AS customers,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)      AS pct,
    SUM(COUNT(*)) OVER (ORDER BY n_orders)            AS cumulative_customers
FROM order_counts
GROUP BY n_orders
ORDER BY n_orders;

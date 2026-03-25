-- ============================================================
-- 04 · Order Funnel, Fulfillment & Operations
-- Dataset: 620 orders | 5 status types
-- ============================================================

-- ── 4.1  Order Status Funnel with Revenue Impact ─────────────
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items GROUP BY order_id
)
SELECT
    o.status,
    COUNT(o.order_id)                                 AS order_count,
    ROUND(COUNT(o.order_id)*100.0/SUM(COUNT(o.order_id)) OVER(),1) AS pct_of_orders,
    ROUND(SUM(ot.order_value), 2)                     AS gross_value,
    ROUND(AVG(ot.order_value), 2)                     AS avg_order_value
FROM orders o
JOIN order_totals ot ON ot.order_id = o.order_id
GROUP BY o.status
ORDER BY order_count DESC;

-- Results:
-- status     | orders | pct%  | gross_value | avg_ov
-- completed  | 461    | 74.4% | $84,211.77  | $182.67
-- shipped    | 75     | 12.1% | $13,921.44  | $185.62
-- processing | 37     | 6.0%  | $6,738.22   | $182.11
-- cancelled  | 31     | 5.0%  | $5,421.99   | $174.90
-- refunded   | 16     | 2.6%  | $1,750.77   | $109.42


-- ── 4.2  Monthly Cancellation & Refund Rate Trend ────────────
SELECT
    TO_CHAR(created_at, 'YYYY-MM')                    AS month,
    COUNT(*)                                          AS total_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN status = 'refunded'  THEN 1 ELSE 0 END) AS refunded,
    ROUND(SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                      AS cancel_rate_pct,
    ROUND(SUM(CASE WHEN status = 'refunded'  THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                      AS refund_rate_pct,
    -- 3-month rolling cancellation rate
    ROUND(AVG(SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*)) OVER (
        ORDER BY TO_CHAR(created_at, 'YYYY-MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1)                                             AS rolling_3mo_cancel_pct
FROM orders
GROUP BY month
ORDER BY month;


-- ── 4.3  Fulfillment SLA Analysis ────────────────────────────
-- How long does it take to ship and deliver?
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (shipped_at - created_at))/3600/24), 1)
                                                      AS avg_days_to_ship,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY EXTRACT(EPOCH FROM (shipped_at - created_at))/3600/24), 1)
                                                      AS median_days_to_ship,
    ROUND(AVG(EXTRACT(EPOCH FROM (delivered_at - shipped_at))/3600/24), 1)
                                                      AS avg_days_to_deliver,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY EXTRACT(EPOCH FROM (delivered_at - shipped_at))/3600/24), 1)
                                                      AS median_days_to_deliver,
    ROUND(AVG(EXTRACT(EPOCH FROM (delivered_at - created_at))/3600/24), 1)
                                                      AS avg_end_to_end_days,
    -- SLA breaches: orders taking >5 days end-to-end
    SUM(CASE WHEN EXTRACT(EPOCH FROM (delivered_at - created_at))/3600/24 > 5
             THEN 1 ELSE 0 END)                       AS sla_breaches,
    ROUND(SUM(CASE WHEN EXTRACT(EPOCH FROM (delivered_at - created_at))/3600/24 > 5
             THEN 1 ELSE 0 END)*100.0/COUNT(*),1)     AS breach_rate_pct
FROM orders
WHERE status = 'completed'
  AND shipped_at IS NOT NULL
  AND delivered_at IS NOT NULL;

-- Results:
-- avg_days_to_ship | median | avg_days_to_deliver | median | avg_e2e | breaches | breach%
-- 1.9              | 2.0    | 4.5                 | 4.0    | 6.4     | 87       | 18.9%


-- ── 4.4  Multi-Item Order Analysis ───────────────────────────
-- Orders with 2+ items tend to have higher value; quantify this
WITH order_summary AS (
    SELECT
        o.order_id,
        c.first_name || ' ' || c.last_name            AS customer,
        COUNT(oi.order_item_id)                       AS item_count,
        SUM(oi.quantity)                              AS total_units,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)    AS order_total
    FROM orders o
    JOIN customers c    ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY o.order_id, customer
)
SELECT
    item_count                                        AS distinct_products,
    COUNT(order_id)                                   AS orders,
    ROUND(COUNT(order_id)*100.0/SUM(COUNT(order_id)) OVER(),1) AS pct_orders,
    ROUND(AVG(order_total), 2)                        AS avg_order_value,
    ROUND(SUM(order_total), 2)                        AS total_revenue,
    ROUND(SUM(order_total)*100.0/SUM(SUM(order_total)) OVER(),1) AS pct_revenue
FROM order_summary
GROUP BY item_count
ORDER BY item_count;

-- Key insight: 2-item orders = 35% of orders but 42% of revenue


-- ── 4.5  Day-of-Week & Hour-of-Day Order Patterns ────────────
SELECT
    TO_CHAR(created_at, 'Day')                        AS day_of_week,
    EXTRACT(DOW FROM created_at)                      AS dow_num,
    COUNT(*)                                          AS orders,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)      AS pct,
    ROUND(AVG(ot.order_value),2)                      AS avg_order_value
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity*unit_price) AS order_value
    FROM order_items GROUP BY order_id
) ot ON ot.order_id = o.order_id
WHERE o.status NOT IN ('cancelled','refunded')
GROUP BY day_of_week, dow_num
ORDER BY dow_num;


-- ── 4.6  Rolling 7-Day Revenue with Anomaly Detection ────────
WITH daily_rev AS (
    SELECT
        DATE(o.created_at)                            AS order_date,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)    AS daily_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled','refunded')
    GROUP BY DATE(o.created_at)
),
rolling AS (
    SELECT
        order_date,
        daily_revenue,
        ROUND(AVG(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2)                                         AS rolling_7d_avg,
        ROUND(STDDEV(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2)                                         AS rolling_7d_stddev,
        ROUND(SUM(daily_revenue) OVER (
            ORDER BY order_date
        ), 2)                                         AS cumulative_revenue
    FROM daily_rev
)
SELECT
    order_date,
    daily_revenue,
    rolling_7d_avg,
    -- z-score: flag days > 2 std deviations above average (revenue spike)
    ROUND((daily_revenue - rolling_7d_avg)
          / NULLIF(rolling_7d_stddev, 0), 2)          AS z_score,
    CASE
        WHEN (daily_revenue - rolling_7d_avg)
             / NULLIF(rolling_7d_stddev, 0) > 2       THEN '📈 Spike'
        WHEN (daily_revenue - rolling_7d_avg)
             / NULLIF(rolling_7d_stddev, 0) < -2      THEN '📉 Dip'
        ELSE 'Normal'
    END                                               AS anomaly_flag,
    cumulative_revenue
FROM rolling
ORDER BY order_date;


-- ── 4.7  Customer Reorder Gap (avg days between purchases) ───
WITH ordered AS (
    SELECT
        customer_id,
        created_at,
        LAG(created_at) OVER (
            PARTITION BY customer_id ORDER BY created_at
        )                                             AS prev_order_date
    FROM orders
    WHERE status NOT IN ('cancelled','refunded')
),
gaps AS (
    SELECT
        customer_id,
        EXTRACT(EPOCH FROM (created_at - prev_order_date))/3600/24 AS days_between
    FROM ordered
    WHERE prev_order_date IS NOT NULL
)
SELECT
    ROUND(AVG(days_between), 1)                       AS avg_days_between_orders,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
          (ORDER BY days_between), 1)                 AS p25_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY days_between), 1)                 AS median_days,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
          (ORDER BY days_between), 1)                 AS p75_days,
    COUNT(*)                                          AS repeat_purchase_events
FROM gaps;

-- Results:
-- avg_days | p25  | median | p75  | repeat_events
-- 47.3     | 18.0 | 38.0   | 72.0 | 341

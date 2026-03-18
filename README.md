# E-Commerce SQL Analytics

End-to-end PostgreSQL analytics project on a normalized 6-table e-commerce schema.
Covers revenue KPIs, customer lifetime value, RFM segmentation, market basket analysis,
fulfillment SLAs, and rolling revenue windows — across **18 months of realistic transaction data**.

**[→ View Live Dashboard](https://tarang-tj.github.io/ecommerce-sql/)**

---

## Dataset

| Table | Rows | Description |
|---|---|---|
| `customers` | 200 | Shoppers across US, UK, Canada, Australia |
| `categories` | 6 | Electronics, Clothing, Home & Garden, Sports, Books, Beauty |
| `products` | 30 | Priced $12.99–$399.99 with stock levels |
| `orders` | 620 | Jan 2024 – Jun 2025, seasonal holiday patterns |
| `order_items` | 1,189 | Line items with quantity and realized unit price |
| `reviews` | 270 | 1–5 star ratings on completed orders |

---

## Schema

```
customers ─────┐
               ├─── orders ──── order_items ──── products ──── categories
               │                                     │
               └─── reviews ─────────────────────────┘
```

All foreign keys are enforced. Orders carry a `status` field
(`completed | shipped | processing | cancelled | refunded`) with delivery timestamps for SLA analysis.

---

## Key Business Findings

### Revenue

**Total GMV: $112,344 across 620 orders (Jan 2024 – Jun 2025)**

| Month | Revenue | MoM Growth | 3-Mo Rolling Avg |
|---|---|---|---|
| 2024-01 | $4,821 | — | $4,821 |
| 2024-06 | $6,418 | +5.2% | $6,107 |
| 2024-10 | $7,892 | +10.4% | $7,219 |
| 2024-11 | $14,832 | **+87.9%** | $10,689 |
| 2024-12 | $18,291 | **+23.3%** | $13,672 |
| 2025-06 | $9,674 | +7.3% | $8,709 |

> **Nov–Dec 2024 holiday spike** drove $33,123 (29.5% of annual GMV) in two months.
> H1 2025 revenue ($47,563) is **+38.4% higher** than H1 2024 ($34,379).

**Revenue by Category:**

| Category | Revenue | Share | Avg Unit Price | Revenue Rank |
|---|---|---|---|---|
| Electronics | $34,821 | 34.3% | $163.42 | #1 |
| Clothing | $17,392 | 17.1% | $63.78 | #2 |
| Sports & Outdoors | $9,184 | 9.0% | $51.39 | #3 |
| Home & Garden | $7,841 | 7.7% | $34.72 | #4 |
| Books | $6,921 | 6.8% | $31.24 | #5 |
| Beauty & Care | $5,490 | 5.4% | $22.17 | #6 |

**Order Value Distribution:**

| Bucket | % of Orders | % of Revenue | Insight |
|---|---|---|---|
| < $50 | 8% | 2% | Low-value impulse buys |
| $50–$99 | 19% | 9% | Accessories, books |
| $100–$199 | 34% | 31% | Sweet spot — clothing + peripherals |
| $200–$349 | 27% | 34% | High-yield; watches, monitors |
| $350+ | 12% | 24% | Monitor-anchored carts |

---

### Customers

**182 of 200 customers placed at least one order (91% activation rate)**

**RFM Segmentation (Recency · Frequency · Monetary — NTILE scoring):**

| Segment | Customers | Avg RFM Score | % of Base | Action |
|---|---|---|---|---|
| Champions | 28 | 14.2 | 18.7% | Reward + upsell |
| Loyal Customers | 41 | 11.8 | 27.3% | Referral program |
| Potential Loyalists | 35 | 9.4 | 23.3% | Targeted offers |
| Recent Customers | 19 | 8.7 | 12.7% | Onboarding sequence |
| At-Risk | 16 | 6.1 | 10.7% | Win-back campaign |
| Lost | 11 | 3.9 | 7.3% | Sunset or deep discount |

**Buyer Loyalty:**

| Segment | Customers | Avg Orders | Avg Spend | Revenue Share |
|---|---|---|---|---|
| One-time buyer | 58 | 1.0 | $147 | 18.7% |
| Repeat buyer (2–3) | 84 | 2.4 | $389 | 47.1% |
| Loyal customer (4+) | 40 | 5.8 | $832 | 34.2% |

> Loyal customers (22% of base) generate **34% of revenue** at 5.7× the spend of one-time buyers.

**Revenue by Country:**

| Country | Customers | Orders | Total Revenue | Avg LTV |
|---|---|---|---|---|
| United States | 110 | 376 | $76,842 | $698.57 |
| United Kingdom | 37 | 118 | $14,202 | $383.83 |
| Canada | 22 | 71 | $7,388 | $335.84 |
| Australia | 13 | 43 | $3,217 | $247.43 |

---

### Products

**Top 8 Products by Revenue:**

| Rank | Product | Category | Revenue | Units | Avg Rating |
|---|---|---|---|---|---|
| 1 | 27" 4K IPS Monitor | Electronics | $18,242 | 46 | 4.7 ⭐ |
| 2 | Smart Watch Series X | Electronics | $12,388 | 49 | 4.6 ⭐ |
| 3 | Wireless Noise-Cancelling Headphones | Electronics | $9,814 | 76 | 4.5 ⭐ |
| 4 | Mechanical Keyboard Tenkeyless | Electronics | $6,832 | 76 | 4.4 ⭐ |
| 5 | Waterproof Running Jacket | Sports | $6,213 | 62 | 4.3 ⭐ |
| 6 | Portable Bluetooth Speaker | Electronics | $5,941 | 99 | 4.5 ⭐ |
| 7 | Merino Wool Crewneck Sweater | Clothing | $4,872 | 61 | 4.4 ⭐ |
| 8 | USB-C Hub 7-in-1 | Electronics | $4,122 | 82 | 4.2 ⭐ |

**Market Basket Analysis — Top Co-Purchase Pairs:**

| Product A | Product B | Co-Purchases | Support | Lift |
|---|---|---|---|---|
| Atomic Habits | The Psychology of Money | 28 | 5.0% | **3.21** |
| USB-C Hub 7-in-1 | Mechanical Keyboard | 24 | 4.3% | **2.87** |
| Vitamin C Serum | Hyaluronic Acid Moisturizer | 21 | 3.8% | **2.91** |
| Compression Leggings | Foam Yoga Mat | 22 | 3.9% | 2.64 |
| Bamboo Charcoal Face Mask | Natural Deodorant Stick | 19 | 3.4% | 2.44 |

> Lift > 1.0 means the pair is bought together more than by chance.
> A lift of 3.21 (books) means customers are **3× more likely** to buy both together than separately.

---

### Orders & Fulfillment

**Order Status Breakdown:**

| Status | Orders | % | Revenue | Avg Order Value |
|---|---|---|---|---|
| Completed | 461 | 74.4% | $84,212 | $182.67 |
| Shipped | 75 | 12.1% | $13,921 | $185.62 |
| Processing | 37 | 6.0% | $6,738 | $182.11 |
| Cancelled | 31 | 5.0% | $5,422 | $174.90 |
| Refunded | 16 | 2.6% | $1,751 | $109.42 |

**Fulfillment SLA (completed orders):**

| Metric | Value |
|---|---|
| Avg days to ship | 1.9 days |
| Median days to ship | 2.0 days |
| Avg days to deliver | 4.5 days |
| Avg end-to-end | 6.4 days |
| SLA breaches (>5 days e2e) | 87 orders (18.9%) |

**Multi-Item Order Impact:**

| Cart Size | % of Orders | % of Revenue |
|---|---|---|
| 1 item | 40% | 22% |
| 2 items | 35% | **42%** |
| 3 items | 18% | 27% |
| 4 items | 7% | 9% |

> 2-item orders punch above their weight — 35% of orders but 42% of revenue.

**Avg days between repeat purchases:** 47.3 days (median: 38.0 days)

---

## Project Structure

```
ecommerce-sql/
│
├── schema/
│   └── schema.sql              # Table definitions, constraints, indexes
│
├── data/
│   └── seed.sql                # 620 orders, 1,189 line items, realistic seasonality
│
├── 01_revenue.sql              # GMV, MoM growth, YoY pivot, rolling avg, distribution
├── 02_customers.sql            # LTV, RFM segments, cohort retention, repeat buyers
├── 03_products.sql             # Leaderboard, category benchmarks, market basket, stock alerts
├── 04_orders.sql               # Funnel, SLA analysis, anomaly detection, reorder gap
│
├── index.html                  # Interactive dashboard (Chart.js, dark theme)
└── INSIGHTS.md                 # Analyst write-up and stakeholder recommendations
```

---

## SQL Techniques Used

| Technique | Where |
|---|---|
| `RANK()`, `DENSE_RANK()`, `NTILE()` | 02_customers, 03_products |
| `LAG()`, `LEAD()` for MoM growth | 01_revenue, 04_orders |
| `SUM() OVER (... ROWS BETWEEN ...)` rolling windows | 01_revenue, 04_orders |
| `PERCENTILE_CONT()` for median & percentiles | 01_revenue, 04_orders |
| `PERCENT_RANK()` for within-category benchmarks | 03_products |
| Multi-CTE pipelines | 02_customers (RFM), 03_products (basket) |
| Conditional aggregation (`CASE WHEN`) for YoY pivot | 01_revenue |
| Z-score anomaly detection | 04_orders |
| Self-join market basket with lift calculation | 03_products |
| `DATE_TRUNC` + cohort joins for retention | 02_customers |

---

## Setup

```bash
# 1. Create database
createdb ecommerce

# 2. Load schema
psql -d ecommerce -f schema/schema.sql

# 3. Load seed data
psql -d ecommerce -f data/seed.sql

# 4. Run any analysis module
psql -d ecommerce -f 01_revenue.sql
```

---

## Author

**TJ Jammalamadaka** — Data & Business Analyst · UW Bothell MIS · Seattle, WA

[Portfolio](https://tarang-tj.github.io) · [LinkedIn](https://linkedin.com/in/tarang-tj) · [GitHub](https://github.com/tarang-tj)

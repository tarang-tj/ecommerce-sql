# 🛒 E-Commerce SQL Analysis (PostgreSQL)

A collection of PostgreSQL data analysis queries for an e-commerce database by covering revenue, customer behaviour, product performance, and order operations.

---

## 📁 Project Structure

```
ecommerce-sql/
├── schema/
│   └── schema.sql          # Table definitions & indexes
├── data/
│   └── seed.sql            # Sample data for local testing
├── analysis/
│   ├── 01_revenue.sql      # Revenue & financial KPIs
│   ├── 02_customers.sql    # Customer segmentation & cohorts
│   ├── 03_products.sql     # Product performance & affinity
│   └── 04_orders.sql       # Order funnel & operations
└── docs/
    └── erd.md              # Entity Relationship overview
```

---

## 🗄️ Schema Overview

| Table | Description |
|---|---|
| `customers` | Registered users |
| `categories` | Hierarchical product categories |
| `products` | Product catalogue with pricing & stock |
| `orders` | Customer orders with status tracking |
| `order_items` | Line items linking orders to products |
| `reviews` | Customer ratings and written reviews |

---

## 🚀 Getting Started

### 1. Prerequisites
- PostgreSQL 14+
- `psql` CLI or a GUI like [TablePlus](https://tableplus.com/) / [DBeaver](https://dbeaver.io/)

### 2. Create the database

```bash
psql -U postgres -c "CREATE DATABASE ecommerce;"
```

### 3. Load schema

```bash
psql -U postgres -d ecommerce -f schema/schema.sql
```

### 4. Seed sample data

```bash
psql -U postgres -d ecommerce -f data/seed.sql
```

### 5. Run analysis queries

```bash
psql -U postgres -d ecommerce -f analysis/01_revenue.sql
```

---

## 📊 Analyses Included

### 01 · Revenue (`01_revenue.sql`)
- Total revenue (excluding cancellations)
- Monthly revenue trend
- Revenue breakdown by category
- Average order value

### 02 · Customers (`02_customers.sql`)
- Top 10 customers by lifetime value
- Revenue by country
- Customer segmentation: one-time / repeat / loyal
- Cohort retention analysis

### 03 · Products (`03_products.sql`)
- Best-selling products by units & revenue
- Review conversion rate per product
- Average ratings leaderboard
- Low stock alerts
- Frequently bought together (market basket)

### 04 · Orders (`04_orders.sql`)
- Order status funnel breakdown
- Cancellation rate by month
- Multi-item orders
- Rolling 7-day revenue window

---

## 💡 Key SQL Techniques Used

- **Window functions** — `SUM() OVER`, `ROWS BETWEEN` for rolling metrics
- **CTEs** — Readable multi-step queries (cohort analysis)
- **CASE expressions** — Customer segmentation logic
- **Aggregations** — `COUNT DISTINCT`, `AVG`, `ROUND`
- **Self-joins** — Market basket / frequently bought together
- **LEFT JOINs** — Ensuring products without reviews still appear

---

## 📄 License

MIT — free to use, fork, and extend.

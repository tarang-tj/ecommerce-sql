# E-Commerce SQL Analytics

End-to-end SQL analysis on a normalized e-commerce schema — covering revenue KPIs, customer lifetime value, market basket analysis, and rolling revenue windows in PostgreSQL.

## Key Business Findings

See [`INSIGHTS.md`](INSIGHTS.md) for the full analyst write-up and stakeholder recommendations.

Highlights from the analysis:
- **Revenue** — period-over-period trends and rolling windows surfaced in `01_revenue.sql`
- **Customers** — lifetime value and segmentation analysis in `02_customers.sql`
- **Products** — top performers and market basket associations in `03_products.sql`
- **Orders** — fulfillment and order-level metrics in `04_orders.sql`

## Project Structure

```
ecommerce-sql/
│
├── data/                  # Seed data files
├── schema/                # Table definitions
│
├── 01_revenue.sql         # Revenue KPIs and rolling windows
├── 02_customers.sql       # Customer lifetime value and segmentation
├── 03_products.sql        # Product performance and market basket analysis
├── 04_orders.sql          # Order-level metrics
│
├── erd.md                 # Entity-relationship diagram
├── INSIGHTS.md            # Analyst insights and stakeholder recommendations
└── index.html             # Dashboard (dark theme)
```

## Database

PostgreSQL. Load the schema and seed data before running the queries:

```sql
psql -d your_database -f schema/your_schema_file.sql
psql -d your_database -f data/your_seed_file.sql
```

Then run any of the numbered `.sql` files in order.

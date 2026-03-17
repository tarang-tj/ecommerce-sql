# Entity Relationship Overview

```
customers
─────────
customer_id  PK
first_name
last_name
email
country
created_at
     │
     │ 1:N
     ▼
orders                    order_items
──────                    ───────────
order_id     PK ──1:N──► order_item_id  PK
customer_id  FK           order_id       FK
status                    product_id     FK ◄── products
created_at                quantity             ──────────
                          unit_price           product_id  PK
                                               name
                                               category_id FK ◄── categories
                                               price             ───────────
                                               stock             category_id PK
                                               created_at        name
                                                                 parent_id   FK (self)

reviews
───────
review_id   PK
product_id  FK ──► products
customer_id FK ──► customers
rating
body
created_at
```

## Relationships

| From | To | Type | Notes |
|---|---|---|---|
| `customers` | `orders` | 1 : N | One customer, many orders |
| `orders` | `order_items` | 1 : N | One order, many line items |
| `products` | `order_items` | 1 : N | One product on many lines |
| `categories` | `products` | 1 : N | Category groups products |
| `categories` | `categories` | 1 : N | Self-join for subcategories |
| `customers` | `reviews` | 1 : N | One customer, many reviews |
| `products` | `reviews` | 1 : N | One product, many reviews |

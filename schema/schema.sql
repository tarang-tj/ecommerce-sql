-- ============================================================
-- E-Commerce Schema — PostgreSQL
-- ============================================================

DROP TABLE IF EXISTS reviews      CASCADE;
DROP TABLE IF EXISTS order_items  CASCADE;
DROP TABLE IF EXISTS orders       CASCADE;
DROP TABLE IF EXISTS products     CASCADE;
DROP TABLE IF EXISTS categories   CASCADE;
DROP TABLE IF EXISTS customers    CASCADE;

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    first_name   TEXT NOT NULL,
    last_name    TEXT NOT NULL,
    email        TEXT UNIQUE NOT NULL,
    country      TEXT NOT NULL,
    city         TEXT,
    created_at   TIMESTAMPTZ NOT NULL
);

CREATE TABLE categories (
    category_id  SERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    description  TEXT
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    name         TEXT NOT NULL,
    category_id  INT REFERENCES categories(category_id),
    price        NUMERIC(10,2) NOT NULL,
    stock        INT NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT REFERENCES customers(customer_id),
    status       TEXT NOT NULL CHECK (status IN ('completed','shipped','processing','cancelled','refunded')),
    created_at   TIMESTAMPTZ NOT NULL,
    shipped_at   TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders(order_id),
    product_id    INT REFERENCES products(product_id),
    quantity      INT NOT NULL,
    unit_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE reviews (
    review_id   SERIAL PRIMARY KEY,
    product_id  INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    rating      INT CHECK (rating BETWEEN 1 AND 5),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for query performance
CREATE INDEX idx_orders_customer    ON orders(customer_id);
CREATE INDEX idx_orders_status      ON orders(status);
CREATE INDEX idx_orders_created     ON orders(created_at);
CREATE INDEX idx_order_items_order  ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product    ON reviews(product_id);

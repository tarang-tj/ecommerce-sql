-- ============================================================
-- E-Commerce Database Schema (PostgreSQL)
-- ============================================================

-- CUSTOMERS
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    country       VARCHAR(100),
    created_at    TIMESTAMP DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    parent_id     INT REFERENCES categories(category_id)
);

-- PRODUCTS
CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    category_id   INT REFERENCES categories(category_id),
    price         NUMERIC(10, 2) NOT NULL,
    stock         INT DEFAULT 0,
    created_at    TIMESTAMP DEFAULT NOW()
);

-- ORDERS
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    status        VARCHAR(50) DEFAULT 'pending',  -- pending, shipped, delivered, cancelled
    created_at    TIMESTAMP DEFAULT NOW()
);

-- ORDER ITEMS
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders(order_id),
    product_id    INT REFERENCES products(product_id),
    quantity      INT NOT NULL,
    unit_price    NUMERIC(10, 2) NOT NULL
);

-- REVIEWS
CREATE TABLE reviews (
    review_id     SERIAL PRIMARY KEY,
    product_id    INT REFERENCES products(product_id),
    customer_id   INT REFERENCES customers(customer_id),
    rating        SMALLINT CHECK (rating BETWEEN 1 AND 5),
    body          TEXT,
    created_at    TIMESTAMP DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_orders_customer    ON orders(customer_id);
CREATE INDEX idx_order_items_order  ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_products_category  ON products(category_id);

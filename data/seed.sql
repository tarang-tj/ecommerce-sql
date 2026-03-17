-- ============================================================
-- Sample Seed Data
-- ============================================================

-- CATEGORIES
INSERT INTO categories (name, parent_id) VALUES
    ('Electronics', NULL),
    ('Clothing',    NULL),
    ('Books',       NULL),
    ('Phones',      1),
    ('Laptops',     1),
    ('Men''s',      2),
    ('Women''s',    2);

-- PRODUCTS
INSERT INTO products (name, category_id, price, stock) VALUES
    ('iPhone 15 Pro',       4,  999.99,  50),
    ('Samsung Galaxy S24',  4,  849.99,  75),
    ('MacBook Pro 14"',     5, 1999.99,  30),
    ('Dell XPS 15',         5, 1499.99,  40),
    ('Men''s Slim Jeans',   6,   59.99, 200),
    ('Women''s Sneakers',   7,   89.99, 150),
    ('Clean Code (Book)',   3,   34.99, 300),
    ('The Pragmatic Programmer', 3, 39.99, 250);

-- CUSTOMERS
INSERT INTO customers (first_name, last_name, email, country) VALUES
    ('Alice',   'Johnson',  'alice@example.com',   'USA'),
    ('Bob',     'Smith',    'bob@example.com',     'UK'),
    ('Carlos',  'Diaz',     'carlos@example.com',  'Spain'),
    ('Diana',   'Lee',      'diana@example.com',   'Canada'),
    ('Ethan',   'Brown',    'ethan@example.com',   'USA'),
    ('Fiona',   'Wilson',   'fiona@example.com',   'Australia'),
    ('George',  'Taylor',   'george@example.com',  'USA'),
    ('Hannah',  'Martinez', 'hannah@example.com',  'Mexico');

-- ORDERS
INSERT INTO orders (customer_id, status, created_at) VALUES
    (1, 'delivered',  '2024-01-15'),
    (1, 'delivered',  '2024-03-22'),
    (2, 'delivered',  '2024-02-10'),
    (3, 'shipped',    '2024-04-05'),
    (4, 'delivered',  '2024-01-30'),
    (5, 'cancelled',  '2024-03-01'),
    (6, 'delivered',  '2024-04-12'),
    (7, 'pending',    '2024-04-20'),
    (8, 'delivered',  '2024-02-28'),
    (1, 'delivered',  '2024-05-01');

-- ORDER ITEMS
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1,  999.99),
    (1, 7, 2,   34.99),
    (2, 3, 1, 1999.99),
    (3, 2, 1,  849.99),
    (3, 8, 1,   39.99),
    (4, 5, 2,   59.99),
    (5, 6, 1,   89.99),
    (6, 4, 1, 1499.99),
    (7, 1, 2,  999.99),
    (8, 7, 3,   34.99),
    (9, 3, 1, 1999.99),
    (10, 2, 1, 849.99),
    (10, 6, 2,  89.99);

-- REVIEWS
INSERT INTO reviews (product_id, customer_id, rating, body) VALUES
    (1, 1, 5, 'Absolutely love this phone!'),
    (1, 5, 4, 'Great camera, battery could be better.'),
    (3, 1, 5, 'Best laptop I have ever owned.'),
    (7, 2, 5, 'A must-read for every developer.'),
    (2, 3, 4, 'Solid Android device.'),
    (6, 4, 3, 'Nice shoes but sizing runs small.');

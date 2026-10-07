-- Schema change: shows up in the branch Schema diff
ALTER TABLE shop.customers
    ADD COLUMN loyalty_tier TEXT NOT NULL DEFAULT 'STANDARD'
    CHECK (loyalty_tier IN ('STANDARD', 'SILVER', 'GOLD'));

-- Data updates
UPDATE shop.customers SET loyalty_tier = 'GOLD'   WHERE email = 'aarav.sharma@example.com';
UPDATE shop.customers SET loyalty_tier = 'SILVER' WHERE email IN ('emily.carter@example.com',
                                                                  'sneha.kulkarni@example.com');

UPDATE shop.orders
SET    status = 'SHIPPED', updated_at = now()
WHERE  status = 'PLACED' AND order_ts < now() - interval '12 hours';

-- New records
INSERT INTO shop.customers (full_name, email, city, loyalty_tier)
VALUES ('Kabir Iyer', 'kabir.iyer@example.com', 'Chennai', 'STANDARD');

INSERT INTO shop.orders (customer_id, product_id, quantity)
SELECT customer_id, 105, 2 FROM shop.customers WHERE email = 'kabir.iyer@example.com';
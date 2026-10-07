-- Databricks notebook source
-- DBTITLE 1,Title
-- MAGIC %md
-- MAGIC # Unity Catalog Table → Lakebase Sync
-- MAGIC
-- MAGIC Step-by-step demo: sync a UC table into a Lakebase Postgres database, verify it, update the source, re-sync, and run cross-source queries. Replace `lakebase_poc1` with your catalog name if different.

-- COMMAND ----------

-- DBTITLE 1,5a: Create source table in UC
CREATE SCHEMA IF NOT EXISTS lakehouse_source.shop_gold;

CREATE OR REPLACE TABLE lakehouse_source.shop_gold.products (
    product_id    INT            NOT NULL,
    product_name  STRING         NOT NULL,
    category      STRING,
    unit_price    DECIMAL(10, 2) NOT NULL,
    stock_qty     INT            NOT NULL,
    updated_at    TIMESTAMP      NOT NULL,
    CONSTRAINT products_pk PRIMARY KEY (product_id)
)
-- Change data feed is required for Triggered / Continuous sync modes
TBLPROPERTIES (delta.enableChangeDataFeed = true);

INSERT INTO lakehouse_source.shop_gold.products VALUES
    (101, 'Laptop 14"',          'Computers',   899.00,  25, current_timestamp()),
    (102, 'Wireless Mouse',      'Accessories', 24.99, 200, current_timestamp()),
    (103, 'Mechanical Keyboard', 'Accessories', 79.00,  80, current_timestamp()),
    (104, '27" Monitor',         'Displays',    249.00,  40, current_timestamp()),
    (105, 'Noise-Cancelling Headphones', 'Audio', 199.00, 60, current_timestamp()),
    (106, 'USB-C Hub',           'Accessories', 39.50, 150, current_timestamp());

SELECT * FROM lakehouse_source.shop_gold.products ORDER BY product_id;

-- COMMAND ----------

-- DBTITLE 1,Change source in UC
-- Price drop
UPDATE lakehouse_source.shop_gold.products
SET    unit_price = 849.00, updated_at = current_timestamp()
WHERE  product_id = 101;

-- Restock
UPDATE lakehouse_source.shop_gold.products
SET    stock_qty = stock_qty + 100, updated_at = current_timestamp()
WHERE  product_id = 105;

-- New product
INSERT INTO lakehouse_source.shop_gold.products VALUES
    (107, 'Webcam 1080p', 'Accessories', 59.00, 90, current_timestamp());
-- =====================================================
-- 01_exploration_dq
-- Purpose : Initial data profiling and quality checks on
--           the 11 Fetch tables in fetch-507007.fetch.
-- Findings:
--   * fact_orders: clean, null pattern matches lifecycle
--   * fact_review: duplicate review_id across orders
--                  (Olist quirk — handled via dedup view later)
-- Author  : Joseph Kennedy
-- Date    : 2026-09-10
-- =====================================================



--- Data Cleaning & Explore 

SELECT 'fact_orders'      AS table_name, COUNT(*) AS n FROM `fetch-507007.fetch.fact_orders`
UNION ALL SELECT 'fact_order_items', COUNT(*) FROM `fetch-507007.fetch.fact_order_items`
UNION ALL SELECT 'fact_payment',     COUNT(*) FROM `fetch-507007.fetch.fact_payment`
UNION ALL SELECT 'fact_review',      COUNT(*) FROM `fetch-507007.fetch.fact_review`
UNION ALL SELECT 'fact_returns',     COUNT(*) FROM `fetch-507007.fetch.fact_returns`
UNION ALL SELECT 'fact_stockouts',   COUNT(*) FROM `fetch-507007.fetch.fact_stockouts`
UNION ALL SELECT 'fact_ad_spend',    COUNT(*) FROM `fetch-507007.fetch.fact_ad_spend`
UNION ALL SELECT 'dim_customer',     COUNT(*) FROM `fetch-507007.fetch.dim_customer`
UNION ALL SELECT 'dim_product',      COUNT(*) FROM `fetch-507007.fetch.dim_product`
UNION ALL SELECT 'dim_seller',       COUNT(*) FROM `fetch-507007.fetch.dim_seller`
UNION ALL SELECT 'dim_inventory',    COUNT(*) FROM `fetch-507007.fetch.dim_inventory`
ORDER BY n DESC;

---Checking for Null Values

SELECT
    COUNTIF(order_id IS NULL)                        AS null_order_id,
    COUNTIF(customer_id IS NULL)                     AS null_customer_id,
    COUNTIF(order_status IS NULL)                    AS null_order_status,
    COUNTIF(order_purchase_timestamp IS NULL)        AS null_purchase_ts,
    COUNTIF(order_approved_at IS NULL)               AS null_approved_ts,
    COUNTIF(order_delivered_carrier_date IS NULL)    AS null_shipped_ts,
    COUNTIF(order_delivered_customer_date IS NULL)   AS null_delivered_ts,
    COUNTIF(order_estimated_delivery_date IS NULL)   AS null_estimated_date,
    COUNTIF(acquisition_channel IS NULL)             AS null_channel,
    COUNTIF(device_type IS NULL)                     AS null_device,
    COUNTIF(order_seq IS NULL)                       AS null_seq,
    COUNT(*) AS total_rows
FROM `fetch-507007.fetch.fact_orders`;

--- Checking for duplicate Keys

-- fact_orders should be unique on order_id
SELECT order_id, COUNT(*) AS n
FROM `fetch-507007.fetch.fact_orders`
GROUP BY order_id
HAVING COUNT(*) > 1
LIMIT 20;

-- fact_order_items should be unique on (order_id, order_item_id)
SELECT order_id, order_item_id, COUNT(*) AS n
FROM `fetch-507007.fetch.fact_order_items`
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
LIMIT 20;

-- dim_product should be unique on product_id
SELECT product_id, COUNT(*) AS n
FROM `fetch-507007.fetch.dim_product`
GROUP BY product_id
HAVING COUNT(*) > 1
LIMIT 20;

-- dim_seller should be unique on seller_id
SELECT seller_id, COUNT(*) AS n
FROM `fetch-507007.fetch.dim_seller`
GROUP BY seller_id
HAVING COUNT(*) > 1
LIMIT 20;

-- dim_customer should be unique on customer_id
SELECT customer_id, COUNT(*) AS n
FROM `fetch-507007.fetch.dim_customer`
GROUP BY customer_id
HAVING COUNT(*) > 1
LIMIT 20;

-- dim_inventory should be unique on (seller_id, product_id)
SELECT seller_id, product_id, COUNT(*) AS n
FROM `fetch-507007.fetch.dim_inventory`
GROUP BY seller_id, product_id
HAVING COUNT(*) > 1
LIMIT 20;

-- fact_returns should be unique on return_id
SELECT return_id, COUNT(*) AS n
FROM `fetch-507007.fetch.fact_returns`
GROUP BY return_id
HAVING COUNT(*) > 1
LIMIT 20;


---Category Distinct count checks

SELECT
    COUNT(DISTINCT order_id)             AS n_unique_orders,
    COUNT(DISTINCT customer_id)          AS n_unique_customers,
    COUNT(DISTINCT order_status)         AS n_order_statuses,
    COUNT(DISTINCT acquisition_channel)  AS n_channels,
    COUNT(DISTINCT device_type)          AS n_devices
FROM `fetch-507007.fetch.fact_orders`;

SELECT order_status,        COUNT(*) AS n FROM `fetch-507007.fetch.fact_orders` GROUP BY 1 ORDER BY n DESC;
SELECT acquisition_channel, COUNT(*) AS n FROM `fetch-507007.fetch.fact_orders` GROUP BY 1 ORDER BY n DESC;
SELECT device_type,         COUNT(*) AS n FROM `fetch-507007.fetch.fact_orders` GROUP BY 1 ORDER BY n DESC;


---Ensuring no fuplicate rows (duplicate reviews found)

WITH dup_check AS (
    SELECT 'fact_orders'      AS table_name, 'order_id'                 AS pk,
           COUNT(*) - COUNT(DISTINCT order_id) AS n_dupes
    FROM `fetch-507007.fetch.fact_orders`

    UNION ALL SELECT 'fact_order_items', 'order_id + order_item_id',
           COUNT(*) - COUNT(DISTINCT CONCAT(order_id, '|', CAST(order_item_id AS STRING)))
    FROM `fetch-507007.fetch.fact_order_items`

    UNION ALL SELECT 'fact_payment', 'order_id + payment_seq',
           COUNT(*) - COUNT(DISTINCT CONCAT(order_id, '|', CAST(payment_seq AS STRING)))
    FROM `fetch-507007.fetch.fact_payment`

    UNION ALL SELECT 'fact_review', 'review_id',
           COUNT(*) - COUNT(DISTINCT review_id)
    FROM `fetch-507007.fetch.fact_review`

    UNION ALL SELECT 'fact_returns', 'return_id',
           COUNT(*) - COUNT(DISTINCT return_id)
    FROM `fetch-507007.fetch.fact_returns`

    UNION ALL SELECT 'fact_stockouts', 'stockout_id',
           COUNT(*) - COUNT(DISTINCT stockout_id)
    FROM `fetch-507007.fetch.fact_stockouts`

    UNION ALL SELECT 'fact_ad_spend', 'week_start + acquisition_channel',
           COUNT(*) - COUNT(DISTINCT CONCAT(CAST(week_start AS STRING), '|', acquisition_channel))
    FROM `fetch-507007.fetch.fact_ad_spend`

    UNION ALL SELECT 'dim_customer', 'customer_id',
           COUNT(*) - COUNT(DISTINCT customer_id)
    FROM `fetch-507007.fetch.dim_customer`

    UNION ALL SELECT 'dim_product', 'product_id',
           COUNT(*) - COUNT(DISTINCT product_id)
    FROM `fetch-507007.fetch.dim_product`

    UNION ALL SELECT 'dim_seller', 'seller_id',
           COUNT(*) - COUNT(DISTINCT seller_id)
    FROM `fetch-507007.fetch.dim_seller`

    UNION ALL SELECT 'dim_inventory', 'seller_id + product_id',
           COUNT(*) - COUNT(DISTINCT CONCAT(seller_id, '|', product_id))
    FROM `fetch-507007.fetch.dim_inventory`
)
SELECT
    table_name,
    pk,
    n_dupes,
    CASE WHEN n_dupes = 0 THEN '✅ clean' ELSE '⚠️ dupes found' END AS status
FROM dup_check
ORDER BY n_dupes DESC, table_name;

---Checking for table inter-relationship issues (Clean)

WITH orphan_check AS (
    SELECT 'fact_order_items → dim_product' AS relationship,
        COUNTIF(p.product_id IS NULL) AS orphan_count,
        COUNT(*) AS total
    FROM `fetch-507007.fetch.fact_order_items` oi
    LEFT JOIN `fetch-507007.fetch.dim_product` p ON p.product_id = oi.product_id

    UNION ALL SELECT 'fact_order_items → dim_seller',
        COUNTIF(s.seller_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_order_items` oi
    LEFT JOIN `fetch-507007.fetch.dim_seller` s ON s.seller_id = oi.seller_id

    UNION ALL SELECT 'fact_order_items → fact_orders',
        COUNTIF(o.order_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_order_items` oi
    LEFT JOIN `fetch-507007.fetch.fact_orders` o ON o.order_id = oi.order_id

    UNION ALL SELECT 'fact_orders → dim_customer',
        COUNTIF(c.customer_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_orders` o
    LEFT JOIN `fetch-507007.fetch.dim_customer` c ON c.customer_id = o.customer_id

    UNION ALL SELECT 'fact_payment → fact_orders',
        COUNTIF(o.order_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_payment` pay
    LEFT JOIN `fetch-507007.fetch.fact_orders` o ON o.order_id = pay.order_id

    UNION ALL SELECT 'fact_review → fact_orders',
        COUNTIF(o.order_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_review` r
    LEFT JOIN `fetch-507007.fetch.fact_orders` o ON o.order_id = r.order_id

    UNION ALL SELECT 'fact_returns → fact_orders',
        COUNTIF(o.order_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_returns` rt
    LEFT JOIN `fetch-507007.fetch.fact_orders` o ON o.order_id = rt.order_id

    UNION ALL SELECT 'fact_returns → dim_product',
        COUNTIF(p.product_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_returns` rt
    LEFT JOIN `fetch-507007.fetch.dim_product` p ON p.product_id = rt.product_id

    UNION ALL SELECT 'fact_stockouts → dim_seller',
        COUNTIF(s.seller_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.fact_stockouts` so
    LEFT JOIN `fetch-507007.fetch.dim_seller` s ON s.seller_id = so.seller_id

    UNION ALL SELECT 'dim_inventory → dim_product',
        COUNTIF(p.product_id IS NULL), COUNT(*)
    FROM `fetch-507007.fetch.dim_inventory` i
    LEFT JOIN `fetch-507007.fetch.dim_product` p ON p.product_id = i.product_id
)
SELECT
    relationship,
    orphan_count,
    total,
    ROUND(orphan_count * 100.0 / total, 4) AS orphan_pct,
    CASE WHEN orphan_count = 0 THEN '✅ clean' ELSE '⚠️ orphans' END AS status
FROM orphan_check
ORDER BY orphan_count DESC;


-- What review_ids appear multiple times? (Understand what to Deduplicate later)
SELECT review_id, COUNT(*) AS n
FROM `fetch-507007.fetch.fact_review`
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY n DESC
LIMIT 20;












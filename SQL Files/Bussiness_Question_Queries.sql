---Gross Merchandise Value GMV---

SELECT
    DATE_TRUNC(DATE(order_purchase_timestamp), MONTH)  AS order_month,
    acquisition_channel,
    COUNT(DISTINCT order_id)                           AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)                AS gmv_brl,
    ROUND(SUM(gross_item_value_brl) / COUNT(DISTINCT order_id), 2) AS aov_brl
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY order_month, acquisition_channel
ORDER BY order_month, gmv_brl DESC;


-- ----------------------------------------------------
-- Q2: Monthly revenue by acquisition channel
-- Question: Which channels drive the growth?
-- ----------------------------------------------------
SELECT
    DATE_TRUNC(DATE(order_purchase_timestamp), MONTH) AS order_month,
    acquisition_channel,
    COUNT(DISTINCT order_id)                          AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)               AS revenue_brl
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY order_month, acquisition_channel
ORDER BY order_month, revenue_brl DESC;


-- ----------------------------------------------------
-- Q3: AOV by acquisition channel (overall)
-- Question: Which channels bring bigger baskets?
-- ----------------------------------------------------
SELECT
    acquisition_channel,
    COUNT(DISTINCT order_id)                                       AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)                            AS revenue_brl,
    ROUND(SUM(gross_item_value_brl) / COUNT(DISTINCT order_id), 2) AS aov_brl
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY acquisition_channel
ORDER BY aov_brl DESC;


-- ----------------------------------------------------
-- Q4: Top product categories by revenue
-- Question: Where is revenue concentrated by category?
-- ----------------------------------------------------
SELECT
    COALESCE(product_category, 'Uncategorized')                    AS product_category,
    COUNT(DISTINCT order_id)                                       AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)                            AS revenue_brl,
    ROUND(SUM(gross_item_value_brl) * 100.0
        / SUM(SUM(gross_item_value_brl)) OVER (), 2)               AS pct_of_total_revenue
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY product_category
ORDER BY revenue_brl DESC
LIMIT 20;


-- ----------------------------------------------------
-- Q5: Top 20 sellers by revenue
-- Question: Long-tail marketplace or a few big sellers?
-- ----------------------------------------------------
SELECT
    seller_id,
    seller_state,
    seller_city,
    COUNT(DISTINCT order_id)                                       AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)                            AS revenue_brl,
    ROUND(SUM(gross_item_value_brl) * 100.0
        / SUM(SUM(gross_item_value_brl)) OVER (), 2)               AS pct_of_total_revenue
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY seller_id, seller_state, seller_city
ORDER BY revenue_brl DESC
LIMIT 20;


-- ----------------------------------------------------
-- Q6: Revenue by seller state (geographic distribution)
-- Question: Where do our sellers ship from?
-- ----------------------------------------------------
SELECT
    seller_state,
    COUNT(DISTINCT seller_id)                                      AS n_sellers,
    COUNT(DISTINCT order_id)                                       AS n_orders,
    ROUND(SUM(gross_item_value_brl), 2)                            AS revenue_brl,
    ROUND(SUM(gross_item_value_brl) * 100.0
        / SUM(SUM(gross_item_value_brl)) OVER (), 2)               AS pct_of_total_revenue
FROM `fetch-507007.fetch.vw_join_orders_items`
WHERE order_status = 'delivered'
GROUP BY seller_state
ORDER BY revenue_brl DESC;


-- ----------------------------------------------------
-- Q7: Order status distribution
-- Question: How healthy is the fulfilment pipeline?
-- ----------------------------------------------------
SELECT
    order_status,
    COUNT(*)                                                       AS n_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)             AS pct_of_orders
FROM `fetch-507007.fetch.fact_orders`
GROUP BY order_status
ORDER BY n_orders DESC;


-- ----------------------------------------------------
-- Q8: Delivery time distribution (delivered orders only)
-- Question: How long does it take to reach the customer?
-- ----------------------------------------------------
SELECT
    APPROX_QUANTILES(
        DATE_DIFF(DATE(order_delivered_customer_date),
                  DATE(order_purchase_timestamp), DAY),
        10
    ) AS delivery_days_deciles,
    ROUND(AVG(
        DATE_DIFF(DATE(order_delivered_customer_date),
                  DATE(order_purchase_timestamp), DAY)
    ), 1) AS avg_delivery_days,
    MIN(DATE_DIFF(DATE(order_delivered_customer_date),
                  DATE(order_purchase_timestamp), DAY)) AS min_delivery_days,
    MAX(DATE_DIFF(DATE(order_delivered_customer_date),
                  DATE(order_purchase_timestamp), DAY)) AS max_delivery_days
FROM `fetch-507007.fetch.fact_orders`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

---Check for abnormally large delivery day (Data Quality issue will be fixed in Python)

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATE_DIFF(DATE(order_delivered_customer_date),
              DATE(order_purchase_timestamp), DAY) AS delivery_days
FROM `fetch-507007.fetch.fact_orders`
WHERE order_status = 'delivered'
  AND DATE_DIFF(DATE(order_delivered_customer_date),
                DATE(order_purchase_timestamp), DAY) > 100
ORDER BY delivery_days DESC
LIMIT 20;


-- ----------------------------------------------------
-- Q9: Late delivery rate (vs estimated date)
-- Question: How often do we miss the promise?
-- ----------------------------------------------------
SELECT
    COUNT(*) AS n_delivered,
    COUNTIF(DATE(order_delivered_customer_date) > order_estimated_delivery_date) AS n_late,
    ROUND(COUNTIF(DATE(order_delivered_customer_date) > order_estimated_delivery_date)
          * 100.0 / COUNT(*), 2) AS late_pct,
    ROUND(AVG(
        CASE WHEN DATE(order_delivered_customer_date) > order_estimated_delivery_date
             THEN DATE_DIFF(DATE(order_delivered_customer_date),
                            order_estimated_delivery_date, DAY)
        END
    ), 1) AS avg_days_late_when_late
FROM `fetch-507007.fetch.fact_orders`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- ----------------------------------------------------
-- Q10: Review score distribution
-- Question: What does the CSAT curve look like?
-- ----------------------------------------------------
SELECT
    review_score,
    COUNT(*)                                                       AS n_reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)             AS pct_of_reviews
FROM `fetch-507007.fetch.fact_review`
GROUP BY review_score
ORDER BY review_score;


-- ----------------------------------------------------
-- Q11: Late delivery impact on review score
-- Question: Do late deliveries actually hurt CSAT?
-- ----------------------------------------------------
SELECT
    CASE
        WHEN DATE(o.order_delivered_customer_date) > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time / Early'
    END AS delivery_status,
    COUNT(*)                       AS n_orders,
    ROUND(AVG(r.review_score), 2)  AS avg_review_score,
    COUNTIF(r.review_score <= 2)   AS n_bad_reviews,
    ROUND(COUNTIF(r.review_score <= 2) * 100.0 / COUNT(*), 2) AS bad_review_rate_pct
FROM      `fetch-507007.fetch.fact_orders` o
LEFT JOIN `fetch-507007.fetch.fact_review` r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
  AND r.review_score IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;


-- ----------------------------------------------------
-- Q12: Return rate by product category
-- Question: Which categories send back the most?
-- ----------------------------------------------------
SELECT
    COALESCE(product_category, 'Uncategorized') AS product_category,
    COUNT(*)                                    AS n_items_sold,
    COUNTIF(is_returned)                        AS n_returned,
    ROUND(COUNTIF(is_returned) * 100.0 / COUNT(*), 2) AS return_rate_pct,
    ROUND(SUM(CASE WHEN is_returned THEN refund_amount_brl END), 2) AS total_refunds_brl
FROM `fetch-507007.fetch.vw_join_items_returns`
GROUP BY product_category
HAVING COUNT(*) >= 100     -- kill noise from tiny categories
ORDER BY return_rate_pct DESC
LIMIT 20;


-- ----------------------------------------------------
-- Q13: Top return reasons
-- Question: Why are customers returning?
-- ----------------------------------------------------
SELECT
    return_reason,
    COUNT(*)                                             AS n_returns,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_returns,
    ROUND(SUM(refund_amount_brl), 2)                     AS total_refunds_brl
FROM `fetch-507007.fetch.fact_returns`
GROUP BY return_reason
ORDER BY n_returns DESC;


-- ----------------------------------------------------
-- Q14: Repeat purchase rate
-- Question: One-off buyers or loyal customers?
-- Note: Uses customer_unique_id (the real person key),
--       NOT customer_id (which is per-order)
-- ----------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS n_orders
    FROM      `fetch-507007.fetch.fact_orders` o
    LEFT JOIN `fetch-507007.fetch.dim_customer` c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN n_orders = 1 THEN '1 order'
        WHEN n_orders = 2 THEN '2 orders'
        WHEN n_orders BETWEEN 3 AND 5 THEN '3-5 orders'
        ELSE '6+ orders'
    END AS buyer_type,
    COUNT(*)                                             AS n_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_customers
FROM customer_orders
GROUP BY buyer_type
ORDER BY buyer_type;


-- ----------------------------------------------------
-- Q15: Revenue at risk from stockouts
-- Question: How much did we potentially lose to running out?
-- ----------------------------------------------------
SELECT
    warehouse_region,
    COUNT(DISTINCT CONCAT(seller_id, '|', product_id))  AS n_products_with_stockouts,
    COUNT(DISTINCT stockout_id)                         AS n_stockout_events,
    SUM(duration_days)                                  AS total_stockout_days,
    SUM(missed_orders_est)                              AS total_missed_orders_est
FROM `fetch-507007.fetch.vw_join_inventory_stockouts`
WHERE stockout_id IS NOT NULL   -- only rows where there was a stockout event
GROUP BY warehouse_region
ORDER BY total_missed_orders_est DESC;
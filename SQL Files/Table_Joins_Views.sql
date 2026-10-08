-- =====================================================
-- 02_joins_views
-- Purpose : Persist the 6 core joins as views in
--           fetch-507007.fetch. These are the foundation
--           for every downstream analysis and Tableau view.
-- Author  : Joseph Kennedy
-- Date    : 2026-09-10
-- Notes   :
--   * All joins use LEFT JOIN — never lose the left-side row.
--   * fact_review dedup NOT applied here; done in a later
--     staging view (vw_review_per_order) when analytics need it.
--   * Grain is documented above each view.
-- =====================================================


-- ----------------------------------------------------
-- Join A → vw_join_orders_items
-- Grain: 1 row per order-item
-- Purpose: revenue, GMV, AOV, category/seller/geo breakdowns
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_orders_items` AS
SELECT
    o.order_id,
    o.customer_id,
    o.acquisition_channel,
    o.device_type,
    o.order_seq,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price          AS price_brl,
    oi.freight_value  AS freight_brl,
    oi.price + oi.freight_value AS gross_item_value_brl,
    p.product_category,
    p.product_weight_g,
    s.seller_state,
    s.seller_city
FROM      `fetch-507007.fetch.fact_orders`      o
LEFT JOIN `fetch-507007.fetch.fact_order_items` oi ON oi.order_id   = o.order_id
LEFT JOIN `fetch-507007.fetch.dim_product`      p  ON p.product_id  = oi.product_id
LEFT JOIN `fetch-507007.fetch.dim_seller`       s  ON s.seller_id   = oi.seller_id;


-- ----------------------------------------------------
-- Join B → vw_join_orders_payments
-- Grain: 1 row per payment line (many-per-order possible — splits are legit)
-- Purpose: payment mix, installments, payment vs order value
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_orders_payments` AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.acquisition_channel,
    pay.payment_seq,
    pay.payment_type,
    pay.installments,
    pay.payment_value_brl
FROM      `fetch-507007.fetch.fact_orders`  o
LEFT JOIN `fetch-507007.fetch.fact_payment` pay ON pay.order_id = o.order_id;


-- ----------------------------------------------------
-- Join C → vw_join_orders_reviews
-- Grain: 1 row per review (multiple-per-order possible — see DQ note)
-- Purpose: CSAT/NPS analysis, review score vs delivery/channel
-- Note: raw fact_review used here; dedup handled downstream.
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_orders_reviews` AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.acquisition_channel,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    r.review_id,
    r.review_score,
    r.review_creation_date,
    r.review_answer_timestamp
FROM      `fetch-507007.fetch.fact_orders` o
LEFT JOIN `fetch-507007.fetch.fact_review` r ON r.order_id = o.order_id;


-- ----------------------------------------------------
-- Join D → vw_join_items_returns
-- Grain: 1 row per order-item (return columns null if item not returned)
-- Purpose: return rate by category/seller/product, refund velocity
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_items_returns` AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.product_category,
    oi.price          AS price_brl,
    oi.freight_value  AS freight_brl,
    rt.return_id,
    rt.return_reason,
    rt.return_requested_date,
    rt.return_completed_date,
    rt.refund_amount_brl,
    rt.restocked,
    rt.return_id IS NOT NULL AS is_returned
FROM      `fetch-507007.fetch.fact_order_items` oi
LEFT JOIN `fetch-507007.fetch.fact_returns`     rt
       ON rt.order_id      = oi.order_id
      AND rt.order_item_id = oi.order_item_id
      AND rt.product_id    = oi.product_id;


-- ----------------------------------------------------
-- Join E → vw_join_inventory_stockouts
-- Grain: 1 row per stockout event (inventory row duplicated across events)
-- Purpose: stockout frequency, revenue-at-risk, stock health by region
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_inventory_stockouts` AS
SELECT
    i.seller_id,
    i.product_id,
    i.snapshot_date,
    i.stock_on_hand,
    i.reorder_point,
    i.safety_stock,
    i.avg_daily_sales,
    i.days_of_cover,
    i.last_restock_date,
    i.warehouse_region,
    i.units_sold_total,
    so.stockout_id,
    so.stockout_start,
    so.stockout_end,
    so.duration_days,
    so.missed_orders_est
FROM      `fetch-507007.fetch.dim_inventory`  i
LEFT JOIN `fetch-507007.fetch.fact_stockouts` so
       ON so.seller_id  = i.seller_id
      AND so.product_id = i.product_id;


-- ----------------------------------------------------
-- Join F → vw_join_adspend_orders
-- Grain: 1 row per (week_start, acquisition_channel, order)
-- Purpose: CAC, ROAS, channel efficiency, weekly spend attribution
-- ----------------------------------------------------
CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_adspend_orders` AS
SELECT
    ad.week_start,
    ad.acquisition_channel,
    ad.spend_brl,
    ad.impressions,
    ad.clicks,
    ad.ctr,
    ad.cpc_brl,
    ad.orders_acquired,
    ad.effective_cac_brl,
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.device_type,
    o.order_seq
FROM      `fetch-507007.fetch.fact_ad_spend` ad
LEFT JOIN `fetch-507007.fetch.fact_orders`   o
       ON o.acquisition_channel = ad.acquisition_channel
      AND DATE_TRUNC(DATE(o.order_purchase_timestamp), WEEK(MONDAY)) = ad.week_start;


SELECT
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_orders_items`)        AS join_a_rows,
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_orders_payments`)     AS join_b_rows,
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_orders_reviews`)      AS join_c_rows,
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_items_returns`)       AS join_d_rows,
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_inventory_stockouts`) AS join_e_rows,
    (SELECT COUNT(*) FROM `fetch-507007.fetch.vw_join_adspend_orders`)      AS join_f_rows;


---Initial error with date parsing on different start dates

CREATE OR REPLACE VIEW `fetch-507007.fetch.vw_join_adspend_orders` AS
SELECT
    ad.week_start,
    ad.acquisition_channel,
    ad.spend_brl,
    ad.impressions,
    ad.clicks,
    ad.ctr,
    ad.cpc_brl,
    ad.orders_acquired,
    ad.effective_cac_brl,
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    o.device_type,
    o.order_seq
FROM      `fetch-507007.fetch.fact_ad_spend` ad
LEFT JOIN `fetch-507007.fetch.fact_orders`   o
       ON o.acquisition_channel = ad.acquisition_channel
      AND DATE_TRUNC(DATE(o.order_purchase_timestamp), WEEK(TUESDAY)) = ad.week_start;























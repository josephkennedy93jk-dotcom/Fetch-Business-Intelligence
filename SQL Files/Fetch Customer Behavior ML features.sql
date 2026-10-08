CREATE OR REPLACE TABLE `fetch-507007.fetch.customer_segmentation_features` AS

WITH dataset_date AS (

    SELECT
        MAX(DATE(order_purchase_timestamp)) AS analysis_date

    FROM `fetch-507007.fetch.fact_orders`

),

payment_features AS (

    SELECT
        order_id,
        SUM(payment_value_brl) AS total_spend,
        AVG(installments) AS avg_installments,
        MAX(installments) AS max_installments,
        COUNT(*) AS payment_count

    FROM `fetch-507007.fetch.fact_payment`

    GROUP BY order_id

),

review_features AS (

    SELECT
        order_id,
        AVG(review_score) AS review_score,
        COUNT(*) AS review_count

    FROM `fetch-507007.fetch.fact_review`

    GROUP BY order_id

),

return_features AS (

    SELECT
        order_id,
        COUNT(return_id) AS returns_count,
        SUM(refund_amount_brl) AS total_refund_amount,
        1 AS return_flag

    FROM `fetch-507007.fetch.fact_returns`

    GROUP BY order_id

)

SELECT
    o.customer_id,
    o.order_id,

    DATE(o.order_purchase_timestamp) AS order_date,

    DATE_DIFF(
        d.analysis_date,
        DATE(o.order_purchase_timestamp),
        DAY
    ) AS recency_days,

    COALESCE(p.total_spend, 0) AS total_spend,

    COALESCE(p.avg_installments, 0) AS avg_installments,

    COALESCE(p.max_installments, 0) AS max_installments,

    COALESCE(p.payment_count, 0) AS payment_count,

    r.review_score,

    CASE
        WHEN r.review_score IS NULL THEN 0
        ELSE 1
    END AS review_available_flag,

    COALESCE(r.review_count, 0) AS review_count,

    COALESCE(rt.returns_count, 0) AS returns_count,

    COALESCE(rt.total_refund_amount, 0) AS total_refund_amount,

    COALESCE(rt.return_flag, 0) AS return_flag,

    SAFE_DIVIDE(
        COALESCE(rt.total_refund_amount, 0),
        NULLIF(p.total_spend, 0)
    ) AS refund_to_spend_ratio,

    o.device_type,

    o.acquisition_channel,

    c.lifecycle_stage,

    c.customer_city,

    c.customer_state

FROM `fetch-507007.fetch.fact_orders` o

LEFT JOIN `fetch-507007.fetch.dim_customer` c
    ON o.customer_id = c.customer_id

LEFT JOIN payment_features p
    ON o.order_id = p.order_id

LEFT JOIN review_features r
    ON o.order_id = r.order_id

LEFT JOIN return_features rt
    ON o.order_id = rt.order_id

CROSS JOIN dataset_date d;



SELECT *
FROM `fetch-507007.fetch.customer_segmentation_features`
LIMIT 30





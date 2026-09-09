-- =============================================================================
-- Project: Google BigQuery E-Commerce & GA4 Event Analytics
-- Query 03: Cart Abandonment Rate & Average Order Value (AOV) Analysis
-- Dataset: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
-- Author: Suat Amet (Data Analyst & BI Specialist)
-- =============================================================================
-- Business Context:
-- Computes cart abandonment dynamics and monetisation KPIs across traffic channels.
-- Identifies lost revenue opportunities where users added items to cart but did not purchase.
-- =============================================================================

WITH ecommerce_sessions AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    device.category AS device_category,
    event_name,
    -- Extract purchase revenue value
    event_value_in_usd,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'currency') AS currency
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN ('add_to_cart', 'purchase')
),

session_cart_summary AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(session_id AS STRING)) AS full_session_id,
    device_category,
    COALESCE(medium, '(none)') AS acquisition_medium,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
    MAX(IF(event_name = 'purchase', 1, 0)) AS completed_purchase,
    SUM(IF(event_name = 'purchase', event_value_in_usd, 0)) AS session_revenue
  FROM
    ecommerce_sessions
  WHERE
    session_id IS NOT NULL
  GROUP BY
    1, 2, 3
)

SELECT
  device_category,
  acquisition_medium,
  -- Cart and Purchase Counts
  COUNTIF(added_to_cart = 1) AS total_cart_sessions,
  COUNTIF(added_to_cart = 1 AND completed_purchase = 1) AS converted_cart_sessions,
  COUNTIF(added_to_cart = 1 AND completed_purchase = 0) AS abandoned_cart_sessions,
  -- Cart Abandonment Rate Percentage
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(added_to_cart = 1 AND completed_purchase = 0),
      COUNTIF(added_to_cart = 1)
    ) * 100, 
    2
  ) AS cart_abandonment_rate_pct,
  -- Revenue and AOV Metrics
  ROUND(SUM(session_revenue), 2) AS total_gross_revenue_usd,
  COUNTIF(completed_purchase = 1) AS total_orders,
  ROUND(
    SAFE_DIVIDE(
      SUM(session_revenue), 
      COUNTIF(completed_purchase = 1)
    ), 
    2
  ) AS average_order_value_usd
FROM
  session_cart_summary
WHERE
  added_to_cart = 1
GROUP BY
  device_category,
  acquisition_medium
HAVING
  total_cart_sessions >= 10
ORDER BY
  total_gross_revenue_usd DESC;

-- =============================================================================
-- Project: Google BigQuery E-Commerce & GA4 Event Analytics
-- Query 01: Multi-Step E-Commerce Conversion Funnel Analysis
-- Dataset: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
-- Author: Suat Amet (Data Analyst & BI Specialist)
-- =============================================================================
-- Business Context:
-- Evaluates the full customer conversion funnel to identify friction points and 
-- stage-by-stage drop-off rates across key e-commerce milestones:
-- 1. session_start -> 2. view_item -> 3. add_to_cart -> 4. begin_checkout -> 5. purchase
-- =============================================================================

WITH raw_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp,
    TIMESTAMP_MICROS(event_timestamp) AS event_datetime,
    -- Extract session ID from nested event parameters
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    -- Extract traffic source medium
    traffic_source.medium AS traffic_medium,
    device.category AS device_category
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
),

session_funnel_flags AS (
  SELECT
    user_pseudo_id,
    session_id,
    device_category,
    traffic_medium,
    -- Identify which stages occurred within each session
    MAX(IF(event_name = 'session_start', 1, 0)) AS has_session_start,
    MAX(IF(event_name = 'view_item', 1, 0)) AS has_view_item,
    MAX(IF(event_name = 'add_to_cart', 1, 0)) AS has_add_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0)) AS has_begin_checkout,
    MAX(IF(event_name = 'purchase', 1, 0)) AS has_purchase
  FROM
    raw_events
  WHERE
    session_id IS NOT NULL
  GROUP BY
    1, 2, 3, 4
),

funnel_aggregates AS (
  SELECT
    device_category,
    COUNT(DISTINCT CONCAT(user_pseudo_id, '-', CAST(session_id AS STRING))) AS total_sessions,
    SUM(has_view_item) AS sessions_viewing_item,
    SUM(has_add_to_cart) AS sessions_adding_to_cart,
    SUM(has_begin_checkout) AS sessions_beginning_checkout,
    SUM(has_purchase) AS sessions_purchasing
  FROM
    session_funnel_flags
  GROUP BY
    device_category
)

SELECT
  device_category,
  total_sessions,
  sessions_viewing_item,
  sessions_adding_to_cart,
  sessions_beginning_checkout,
  sessions_purchasing,
  -- Stage-to-Stage Conversion Rates
  ROUND(SAFE_DIVIDE(sessions_viewing_item, total_sessions) * 100, 2) AS view_item_rate_pct,
  ROUND(SAFE_DIVIDE(sessions_adding_to_cart, sessions_viewing_item) * 100, 2) AS cart_add_rate_pct,
  ROUND(SAFE_DIVIDE(sessions_beginning_checkout, sessions_adding_to_cart) * 100, 2) AS checkout_start_rate_pct,
  ROUND(SAFE_DIVIDE(sessions_purchasing, sessions_beginning_checkout) * 100, 2) AS checkout_to_purchase_rate_pct,
  -- Overall End-to-End Funnel Conversion Rate
  ROUND(SAFE_DIVIDE(sessions_purchasing, total_sessions) * 100, 2) AS overall_funnel_conversion_pct
FROM
  funnel_aggregates
ORDER BY
  total_sessions DESC;

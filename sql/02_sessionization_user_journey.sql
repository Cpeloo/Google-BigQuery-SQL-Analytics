-- =============================================================================
-- Project: Google BigQuery E-Commerce & GA4 Event Analytics
-- Query 02: Event Sessionization & User Journey Analysis
-- Dataset: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
-- Author: Suat Amet (Data Analyst & BI Specialist)
-- =============================================================================
-- Business Context:
-- Reconstructs session journeys, measures session durations, landing pages, 
-- exit pages, and pageview counts using Window Functions.
-- Helps product and marketing teams identify high-engagement paths vs bounces.
-- =============================================================================

WITH session_events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    event_timestamp,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    -- Extract page location path
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    device.category AS device_category,
    geo.country AS user_country,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201201' AND '20201231'
),

ordered_events AS (
  SELECT
    *,
    -- Identify the first event in the session (Landing page)
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id, session_id 
      ORDER BY event_timestamp ASC
    ) AS event_seq_asc,
    -- Identify the last event in the session (Exit page)
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id, session_id 
      ORDER BY event_timestamp DESC
    ) AS event_seq_desc
  FROM
    session_events
  WHERE
    session_id IS NOT NULL
),

session_metrics AS (
  SELECT
    user_pseudo_id,
    session_id,
    device_category,
    user_country,
    traffic_medium,
    COUNT(1) AS total_events,
    COUNTIF(event_name = 'page_view') AS total_pageviews,
    MIN(event_time) AS session_start_time,
    MAX(event_time) AS session_end_time,
    TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), SECOND) AS session_duration_seconds,
    -- Extract landing page and exit page
    MAX(IF(event_seq_asc = 1, page_location, NULL)) AS landing_page,
    MAX(IF(event_seq_desc = 1, page_location, NULL)) AS exit_page
  FROM
    ordered_events
  GROUP BY
    1, 2, 3, 4, 5
)

SELECT
  device_category,
  traffic_medium,
  COUNT(DISTINCT CONCAT(user_pseudo_id, '-', CAST(session_id AS STRING))) AS total_sessions,
  ROUND(AVG(total_pageviews), 2) AS avg_pageviews_per_session,
  ROUND(AVG(session_duration_seconds), 1) AS avg_session_duration_sec,
  -- Calculate bounce rate: sessions with 1 pageview and duration < 10 seconds
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(total_pageviews <= 1 AND session_duration_seconds < 10), 
      COUNT(1)
    ) * 100, 
    2
  ) AS bounce_rate_pct
FROM
  session_metrics
GROUP BY
  device_category,
  traffic_medium
HAVING
  total_sessions > 100
ORDER BY
  total_sessions DESC;

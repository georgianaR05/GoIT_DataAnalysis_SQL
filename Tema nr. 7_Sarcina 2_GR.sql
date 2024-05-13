WITH conversion_data AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS date,
    traffic_source.source,
    traffic_source.medium,
   (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS campaign,
    COUNT(DISTINCT CONCAT(user_pseudo_id, "-", (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id'))) AS user_session_count,
    SUM(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS total_add_to_cart,
    SUM(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS total_begin_checkout,
    SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS total_purchase
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
  GROUP BY
    date,
    source,
    medium,
    campaign)
  SELECT
    date,
    medium,
    SUM(total_add_to_cart) / SUM(user_session_count) * 100 AS visit_to_cart_conversion_rate,
    SUM(total_begin_checkout) / SUM(user_session_count) * 100 AS visit_to_checkout_conversion_rate,
    SUM(total_purchase) / SUM(user_session_count) * 100 AS visit_to_purchase_conversion_rate
  FROM
    conversion_data
  WHERE 
    user_session_count > 0
  GROUP BY
    date,
    medium
  LIMIT 1000
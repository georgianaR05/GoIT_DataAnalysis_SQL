SELECT 
  TIMESTAMP_MICROS(event_timestamp) AS _timestamp,
  user_pseudo_id,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
  event_name,
  geo.country,
  device.category,
  traffic_source.source,
  traffic_source.medium,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS campaign
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  LEFT(event_date, 4) = "2021" AND 
  event_name IN ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase')
LIMIT 1000
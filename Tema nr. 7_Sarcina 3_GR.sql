WITH landing_page AS (
  SELECT
    SUBSTR(REGEXP_EXTRACT((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'), r'^https?://[^/]+(/[^?#]*)'), 2) AS page_path,
    CONCAT(user_pseudo_id, "-", (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS user_session_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY
    page_path,
    user_session_id),
  purchases AS (
    SELECT
      page_path,
      COUNT(DISTINCT user_session_id) AS user_session_count,
      COUNTIF(user_session_id IN (
        SELECT
         CONCAT(user_pseudo_id, "-", (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS user_session_id
        FROM
          `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
        WHERE
          event_name = 'purchase'
        GROUP BY
          user_session_id)) AS total_purchase
    FROM
      landing_page
    GROUP BY
      page_path)
SELECT
  page_path,
  user_session_count,
  SUM(total_purchase) AS total_purchases,
  ROUND(SUM(total_purchase)/SUM(user_session_count) * 100, 2) as conversion
FROM
  purchases
GROUP BY
  page_path,
  user_session_count
LIMIT 1000
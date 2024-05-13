WITH campanii_fb_google AS 
  (
  SELECT 
    ad_date,
    campaign_name,
    sum(spend) AS total_spend, 
    sum(impressions) AS total_impressions, 
    sum(reach) AS total_reach, 
    sum(clicks) AS total_clicks, 
    sum(leads) AS total_leads, 
    sum(value) AS total_value
  FROM 
    facebook_ads_basic_daily fabd 
    LEFT JOIN facebook_campaign fc 
    ON fabd.campaign_id = fc.campaign_id
  GROUP BY 
    ad_date, 
    campaign_name
  UNION ALL
  SELECT 
    ad_date,
    campaign_name,
    sum(spend) AS total_spend, 
    sum(impressions) AS total_impressions, 
    sum(reach) AS total_reach, 
    sum(clicks) AS total_clicks, 
    sum(leads) AS total_leads, 
    sum(value) AS total_value
  FROM 
    google_ads_basic_daily
  GROUP BY 
    ad_date, 
    campaign_name
  )
SELECT 
  ad_date,
  campaign_name,
  sum(total_spend) AS total_cost, 
  sum(total_impressions) AS no_impressions, 
  sum(total_clicks) AS no_clicks, 
  sum(total_value) AS total_conversion_value
FROM 
  campanii_fb_google
WHERE 
  total_spend > 0
GROUP BY 
  ad_date, 
  campaign_name
ORDER BY 
  ad_date;

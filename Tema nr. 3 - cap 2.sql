with campanii_fb_google as 
(select ad_date,
campaign_name,
sum(spend) as total_spend, sum(impressions) as total_impressions, sum(reach) as total_reach, 
sum(clicks) as total_clicks, sum(leads) as total_leads, sum(value) as total_value
from  facebook_ads_basic_daily fabd 
left join facebook_campaign fc on fabd.campaign_id = fc.campaign_id
group by ad_date, campaign_name
union all
select ad_date,
campaign_name,
sum(spend) as total_spend, sum(impressions) as total_impressions, sum(reach) as total_reach, 
sum(clicks) as total_clicks, sum(leads) as total_leads, sum(value) as total_value
from google_ads_basic_daily
group by ad_date, campaign_name)
select ad_date,
campaign_name,
sum(total_spend) as total_cost, sum(total_impressions) as no_impressions, sum(total_clicks) as no_clicks, sum(total_value) as total_conversion_value
from campanii_fb_google
where total_spend > 0
group by ad_date, campaign_name
order by ad_date;
SELECT 
	ad_date,
	campaign_id,
	SUM(spend) as "Cost_Total",
	SUM(impressions) as "Nr. impresii",
	SUM (clicks) as "Nr. click-uri",
	SUM (value) as "Valoarea totala a conversiei",
	SUM (spend) / SUM (clicks) AS "CPC",
	SUM (spend) /SUM (impressions) :: float * 1000 as "CPM",
	(SUM (clicks) / SUM (impressions):: float) * 100 as "CTR",
	((SUM (value) - sum (spend))/ SUM (spend):: float) * 100 as "ROMI"
FROM 
	facebook_ads_basic_daily
WHERE 
	clicks  > 0 and 
	impressions > 0
GROUP BY 
	ad_date, 
	campaign_id;
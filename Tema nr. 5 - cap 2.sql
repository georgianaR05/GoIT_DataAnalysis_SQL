with campanii_fb_g as (
	select 
		fabd.ad_date,
	    fabd.url_parameters,
	    fabd.spend,
	    fabd.impressions,
	    fabd.reach,
	    fabd.clicks,
	    fabd.leads,
	    fabd.value
	from  
		facebook_ads_basic_daily fabd 
	left join 
		facebook_campaign fc on fabd.campaign_id = fc.campaign_id
	union all
	select 
		gabd.ad_date,
		gabd.url_parameters,
		gabd.spend,
	    gabd.impressions,
	    gabd.reach,
	    gabd.clicks,
	    gabd.leads,
	    gabd.value
	from 
		google_ads_basic_daily gabd
)
select 
	ad_date, 
	url_parameters,
	case (LOWER(substring(url_parameters, '.+utm_campaign=(.*)$')))
	when 'nan' 
	then null
	else (LOWER(substring(url_parameters, '.+utm_campaign=(.*)$')))
	end utm_campaign,
	coalesce (sum(spend),0) as total_spend,
	coalesce (sum(impressions),0) as total_impressions,
	coalesce (sum(reach),0) as total_reach,
	coalesce(sum(clicks),0) as total_clicks,
	coalesce(sum(leads),0) as total_leads,
	coalesce(sum(value),0) as total_value,
	case when SUM(impressions) > 0 then (SUM (clicks) / SUM (impressions):: float) * 100
	else null
	end "CTR",
	case when SUM(clicks) > 0 then SUM (spend) / SUM (clicks)
	else null
	end "CPC",
	case when SUM(impressions) > 0 then SUM (spend) /SUM (impressions) :: float * 1000
	else null
	end "CPM",
	case when SUM(spend) > 0 then ((SUM (value) - sum (spend))/ SUM (spend):: float) * 100
	else null
	end "ROMI"
from 
	campanii_fb_g
group  by 
	ad_date, 
	url_parameters
order by
	ad_date;
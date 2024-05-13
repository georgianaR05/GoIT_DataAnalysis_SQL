with previous_homework as (with campanii_fb_g as (
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
		date_trunc ('month', ad_date) as ad_month,
		case (LOWER(substring(decode_url_part (url_parameters), '.+utm_campaign=(.*)$')))
		when 'nan'
		then null
		else (LOWER(substring(decode_url_part (url_parameters), '.+utm_campaign=(.*)$')))
		end utm_campaign,
		coalesce (sum(spend),0) as total_spend,
		coalesce (sum(impressions),0) as total_impressions,
		coalesce (sum(reach),0) as total_reach,
		coalesce(sum(clicks),0) as total_clicks,
		coalesce(sum(leads),0) as total_leads,
		coalesce(sum(value),0) as total_value,
		case when SUM(impressions) > 0 
			 then (SUM (clicks) / SUM (impressions):: float) * 100
		else null
		end CTR,
		case when SUM(clicks) > 0 
			 then SUM (spend) / SUM (clicks)
		else null
		end CPC,
		case when SUM(impressions) > 0 
			 then SUM (spend) /SUM (impressions) :: float * 1000
		else null
		end CPM,
		case when SUM(spend) > 0 
			 then ((SUM (value) - sum (spend))/ SUM (spend):: float) * 100
		else null
		end ROMI
	from
		campanii_fb_g
	group by
		ad_date,
		url_parameters),
previous_metrics as (
	select
		ad_month,
		utm_campaign,
		AVG (CTR) as AVG_CTR,
		AVG (CPM) as AVG_CPM,
		AVG (ROMI) as AVG_ROMI,
		lag(AVG(CTR), 1) over (partition by utm_campaign order by ad_month ASC) as previous_CTR,
		lag(AVG(CPM), 1) over (partition by utm_campaign order by ad_month ASC) as previous_CPM,
		lag(AVG(ROMI), 1) over (partition by utm_campaign order by ad_month ASC) as previous_ROMI
	from 
		previous_homework
	group by 
		ad_month, 
		utm_campaign)
select 
	ad_month, 
	utm_campaign,
	case when previous_ctr > 0 
		 then (avg_ctr-previous_ctr) / previous_ctr * 100 
	else null
	end diff_ctr,
	case when previous_cpm > 0
		 then (avg_cpm-previous_cpm) / previous_cpm * 100
	else null
	end diff_cpm,
	case when previous_romi > 0
		 then (avg_romi-previous_romi) / previous_romi * 100
	else null
	end diff_romi
from 
	previous_metrics;

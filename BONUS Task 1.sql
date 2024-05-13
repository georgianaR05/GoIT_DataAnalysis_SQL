select *
from (
	select
		campaign_id,
		((sum(value) - sum(spend))/sum(spend)::FLOAT)*100 as ROMI
	from 
		facebook_ads_basic_daily
	where 
		campaign_id is not null
	group by 
		campaign_id
	having 
		sum(spend) >500000) as table1
group by 
	campaign_id, 
	ROMI
order by 
	ROMI desc
limit 1;

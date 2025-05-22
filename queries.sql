-- Top 5 funded startups

select startup_name,funding_amount_usd
from funding
order by funding_amount_usd desc
limit 5;

-- Startups with hghest ltv/cac ratio

select startup_name,ltv_cac_ratio
from metrics
where ltv_cac_ratio is not null
order by ltv_cac_ratio desc
limit 5;

-- Startups with the longest runway

select startup_name,runway_months
from metrics
order by runway_months desc
limit 5;


--- Startups with top 5 highest mrr startups

select startup_name,mrr
from metrics
order by mrr desc
limit 5;


--- startups with null ltv/cac ratio(data quality check)

select startup_name
from metrics
where ltv_cac_ratio is NULL;


--- categorizing burn rate (case usage)

select startup_name,burn_rate_usd,
	CASE
		when burn_rate_usd>=50000 then 'High burn'
		when burn_rate_usd between 20000 and 49999 then 'Moderate Burn'
		else 'Low burn'
	end as burn_category
from metrics;


-- startups grouped by runway_buckets (Group by + case)

SELECT 		
	CASE 	
		WHEN runway_months >=100 then '100+ months'
		WHEN runway_months between 50 and 99 then '50-99 months'
		else '<50 months'
	END as runway_group,
	count(*) as total_startups
from metrics
group by runway_group;

		
--- Rank startups by MRR (window function)

select startup_name,mrr,
	rank() over(order by mrr desc) as mrr_rank
from metrics;


-- Correlation check : mRR vs burn rate

select corr(mrr::NUMERIC,burn_rate_usd) as correlation_mrr_burn
from metrics
where mrr is not null and burn_rate_usd IS NOT NULL;

-- Funding efficiency: $usd per mrr dollar

select f.startup_name,f.funding_amount_usd,m.arr,ROUND(f.funding_amount_usd::NUMERIC/NULLIF(m.mrr,0),2) AS usd_per_mrr
from funding f
join metrics m on f.startup_name=m.startup_name;


--- Top 5 most efficient startups by ltv/cac ratio, after removing outliers


SELECT startup_name, ltv_cac_ratio
FROM metrics
WHERE ltv_cac_ratio IS NOT NULL AND ltv_cac_ratio < 1000
ORDER BY ltv_cac_ratio DESC
LIMIT 5;



---- Startups with burn rate above median [With clause]

with median as(
	select percentile_cont(0.5) within group (order by burn_rate_usd) as med
	from metrics
)

select m.startup_name, m.burn_rate_usd
from metrics m
join median on m.burn_rate_usd>median.med;


--- startups with no funding data[left join] [Cross table query]

SELECT s.name as startup_name
from startups s 
left join funding f on s.name=f.startup_name
where f.startup_name is null;


--- % of profitable startups[subquery:]

SELECT 
    ROUND(100.0 * (
        SELECT COUNT(*) FROM startups WHERE profitability_status = 'Profitable'
    ) / COUNT(*), 2) AS profit_percent
FROM startups;


--- Convert each startup key metrics to json

select startup_name,JSON_BUILD_OBJECT(
	'MRR',mrr,
	'CAC',cac,
	'LTV',ltv,
	'LTV_CAC',ltv_cac_ratio,
	'BurnRate',burn_rate_usd
) as startup_metrics
from metrics;


--- Regex - find startups with 2 consecutive capital letters in name

select name
from startups
where name~'[A-Z]{2}';


--- Startups ordered by funding round category (custom orderby)

select startup_name, funding_round
from funding 
order by
	case funding_around
		when 'Series A' THEN 1
		WHEN 'Seed' THEN 2
		WHEN 'Pre-Seed' THEN 3
		ELSE 4
	END;



--- Profitabilty insight per funding round (combines join, groupby, avg, case)
SELECT 
    f.funding_round,
    COUNT(*) AS total,
    ROUND(AVG(CASE WHEN s.profitability_status = 'Profitable' THEN 1 ELSE 0 END) * 100, 2) AS profit_percent
FROM funding f
JOIN startups s ON s.name = f.startup_name
GROUP BY f.funding_round
ORDER BY profit_percent DESC;



--- Find the most efficiently funded startups. (Uses join, null if, round, order by)

SELECT 
    f.startup_name,
    f.funding_amount_usd,
    m.mrr,
    ROUND(f.funding_amount_usd::NUMERIC / NULLIF(m.mrr, 1), 2) AS funding_per_mrr
FROM funding f
JOIN metrics m ON f.startup_name = m.startup_name
WHERE m.mrr > 0
ORDER BY funding_per_mrr ASC
LIMIT 5;


--- Detect outliers in burn rate (uses percentiles, filtering, subqueries))

WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY burn_rate_usd) AS p90
    FROM metrics
)
SELECT startup_name, burn_rate_usd
FROM metrics, stats
WHERE burn_rate_usd > stats.p90;

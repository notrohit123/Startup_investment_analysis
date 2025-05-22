COPY startups(name, category, country, city, founding_year, team_size, revenue_model, profitability_status)
FROM 'E:\startup-investment-analysis\data\processed\startups.csv'
DELIMITER ',' CSV HEADER;


COPY funding(startup_name, funding_round, funding_amount_usd, investors)
FROM 'E:\startup-investment-analysis\data\processed\funding.csv'
DELIMITER ',' CSV HEADER;


COPY metrics(startup_name, mrr, cac, ltv, churn_rate, runway_months, ltv_cac_ratio, burn_rate_usd)
FROM 'E:\startup-investment-analysis\data\processed\metrics.csv'
DELIMITER ',' CSV HEADER
NULL AS '';


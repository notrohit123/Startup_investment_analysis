

CREATE TABLE startups (
    startup_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE,
    category VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    founding_year INT,
    team_size INT,
    revenue_model VARCHAR(100),
    profitability_status VARCHAR(30)
);

CREATE TABLE funding (
    id SERIAL PRIMARY KEY,
    startup_name VARCHAR(100),
    funding_round VARCHAR(30),
    funding_amount_usd BIGINT,
    investors TEXT,
    FOREIGN KEY (startup_name) REFERENCES startups(name)
);

CREATE TABLE metrics (
    id SERIAL PRIMARY KEY,
    startup_name VARCHAR(100),
    mrr INT,
    cac INT,
    ltv INT,
    churn_rate DECIMAL(5,3),
    runway_months INT,
    ltv_cac_ratio DECIMAL(10,2),
    burn_rate_usd DECIMAL(12,2),
    FOREIGN KEY (startup_name) REFERENCES startups(name)
);


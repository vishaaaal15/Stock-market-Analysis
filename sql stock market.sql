CREATE DATABASE Stock_Market;
USE Stock_Market;

CREATE TABLE Dim_Exchange(
exchange_id	INT PRIMARY KEY,
exchange_name VARCHAR(10),
country	VARCHAR (10),
currency VARCHAR (10));

DESC Dim_Exchange;
SELECT * FROM Dim_Exchange; 

CREATE TABLE Dim_Sector(
sector_id VARCHAR (30) PRIMARY KEY,	
sector_name VARCHAR (30));

DESC Dim_Sector;
SELECT * FROM Dim_Sector;

CREATE TABLE Dim_Company(
company_id	VARCHAR (100) PRIMARY KEY,
ticker	VARCHAR (100),
company_name VARCHAR (100),	
sector_id	VARCHAR (100),
exchange_id VARCHAR (100),
FOREIGN KEY (sector_id) REFERENCES dim_sector(sector_id),
FOREIGN KEY (exchange_id) REFERENCES dim_exchange(exchange_id)
);

DESC Dim_Company;
SELECT * FROM Dim_Company;

CREATE TABLE Dim_Trader(
trader_id VARCHAR (100) PRIMARY KEY,
trader_name	VARCHAR (100),
desk VARCHAR (100));

DESC Dim_Trader;
SELECT * FROM Dim_Trader;

CREATE TABLE Dim_Portfolio(
portfolio_id VARCHAR (50) PRIMARY KEY,
portfolio_name	VARCHAR (100),
manager VARCHAR (100));

DESC Dim_Portfolio;
SELECT * FROM Dim_Portfolio;

CREATE TABLE Dim_Calender(
date DATE,
calendar_id	INT PRIMARY KEY,
year_C	YEAR,
month_C INT,
day_C INT,
is_month_start VARCHAR(20));

DESC dim_calender;
SELECT * FROM dim_calender;

CREATE TABLE fact_daily_prices(
date DATE,
company_id VARCHAR(100),	
open DECIMAL(10,2),	
high DECIMAL(10,2),	
low	DECIMAL(10,2),	
close DECIMAL(10,2),	
volume	INT,
calendar_id	INT,
cumulative_factor DECIMAL(2,1),	
adjusted_close DECIMAL(10,2),		
avg_vol DECIMAL(10,2),	
is_volume_suspect VARCHAR(10),	
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id)
);

DESC fact_daily_prices;
select* from fact_daily_prices;

CREATE TABLE fact_dividends(
date DATE,
company_id	VARCHAR(100),
dividend_per_share	DECIMAL(5,2),
calendar_id	INT,
exchange_id	VARCHAR(20),
is_orphan_dividend VARCHAR(20),
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(exchange_id) REFERENCES Dim_exchange(exchange_id)
);

DESC fact_dividends;
select* from fact_dividends;

CREATE TABLE fact_splits(
company_id	VARCHAR(100),
date DATE,
split_ratio	DECIMAL(5,2),
calendar_id	INT,
exchange_id VARCHAR(20),
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(exchange_id) REFERENCES Dim_exchange(exchange_id)
);

DESC fact_splits;
select* from fact_splits;

CREATE TABLE fact_orders(	
order_id VARCHAR(100) PRIMARY KEY,
order_ts DATE,
company_id	VARCHAR(100),
side VARCHAR(30),
quantity INT,
status VARCHAR(20),
order_type	VARCHAR(20),
trader_id VARCHAR(100),
portfolio_id VARCHAR(100),	
date DATE,
calendar_id	INT,
order_ts_imputed VARCHAR(30),
limit_price_imputed	VARCHAR(30),
portfolio_id_imputed VARCHAR(30),
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(trader_id) REFERENCES Dim_trader(trader_id),
FOREIGN KEY(portfolio_id) REFERENCES Dim_portfolio(portfolio_id)
);

DESC fact_orders;
select* from fact_orders;

CREATE TABLE fact_trades(
trade_id VARCHAR(100) PRIMARY KEY,
order_id VARCHAR(100),
trade_ts DATE,
company_id	VARCHAR(100),
side  VARCHAR(30),	
quantity INT,	
price DECIMAL(10,2),
fees  DECIMAL(10,2),	
trader_id VARCHAR(100),
portfolio_id VARCHAR(100),	
date DATE,
calendar_id INT,	
trade_ts_imputed VARCHAR(30),	
fees_imputed VARCHAR(30),
portfolio_id_imputed VARCHAR(30),	
is_orphan_trade VARCHAR(30),
FOREIGN KEY(order_id) REFERENCES fact_orders(order_id),
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(trader_id) REFERENCES Dim_trader(trader_id),
FOREIGN KEY(portfolio_id) REFERENCES Dim_portfolio(portfolio_id)
);

DESC fact_trades;
select* from fact_trades;

CREATE TABLE fact_position_snapshot(
portfolio_id VARCHAR(100),	
company_id	VARCHAR(100),
date DATE,
quantity INT,	
calendar_id INT,
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(portfolio_id) REFERENCES Dim_portfolio(portfolio_id)
);

DESC fact_position_snapshot;
select* from fact_position_snapshot;

CREATE TABLE stocks(
ticker VARCHAR(20),
company_name VARCHAR(100),
exchange	VARCHAR(20),
sector	VARCHAR(50),
currency	VARCHAR(20),
share_price	INT,
outstanding_shares	INT,
market_cap	INT,
quantity	INT,
buy_price DECIMAL(20,10),
initial_value DECIMAL(20,10),
current_price INT,
current_value INT,
return_pct DECIMAL(20,10)
);

DESC stocks;
select* from stocks;

CREATE TABLE fact_trade_pnl_kpi(
Portfolio_id varchar(100),
company_id	VARCHAR(100),
sell_trade_id	VARCHAR(100),
trader_id VARCHAR(100),
sell_date	DATE,
calendar_id	INT,
sell_price	DECIMAL(20,10),
quantity_sold	INT,
gross_sell_amount	DECIMAL(20,10),
gross_buy_amount	DECIMAL(20,10),
allocated_buy_fees DECIMAL(20,10),
allocated_sell_fees DECIMAL(20,10),
total_fees_allocated DECIMAL(20,10),
avg_buy_price DECIMAL(20,10),
total_cost_basis DECIMAL(20,10),
realized_profit	DECIMAL(20,10),
return_pct	DECIMAL(20,10),
win_flag INT,
FOREIGN KEY(company_id) REFERENCES Dim_Company(company_id),
FOREIGN KEY(calendar_id) REFERENCES Dim_Calender(calendar_id),
FOREIGN KEY(trader_id) REFERENCES Dim_trader(trader_id),
FOREIGN KEY(portfolio_id) REFERENCES Dim_portfolio(portfolio_id),
FOREIGN KEY(sell_trade_id) REFERENCES fact_trades(trade_id)
);

DESC fact_trade_pnl_kpi;
SELECT * FROM fact_trade_pnl_kpi;
-----------------------------------------------------------------------------------------
select* from fact_daily_prices;
select* from fact_dividends;
select* from fact_splits;
select* from fact_orders;
select* from fact_trades;
select* from fact_position_snapshot;
select* from stocks;
SELECT * FROM dim_sector;
SELECT * FROM fact_trade_pnl_kpi;

# Total Market Cap
SELECT concat((sum(market_cap)/1000000),"M") AS Total_market_cap
FROM stocks;

# Avg trading volume
SELECT round(avg(avg_vol),2) AS avg_trading_volume
FROM fact_daily_prices;


# Avg Daily returns
with previous_close_price AS
	(SELECT date , company_id , close ,
	lag(close) OVER(partition by company_id) AS previous_close     -- PREVIOUS DAY CLOSE PRICE --
	FROM fact_daily_prices)
SELECT date, 
	company_id , 
    close , 
    previous_close , 
    concat(round(((close - previous_close)/previous_close)*100,2)," %") AS daily_return   -- DAILY RETURN --
FROM previous_close_price;



# Volatility by company
WITH previous_close_price AS (
    SELECT 
        date,
        company_id,
        close,
        LAG(close) OVER(PARTITION BY company_id ORDER BY date) AS previous_close      -- PREVIOUS DAY CLOSE PRICE --
    FROM fact_daily_prices
),
daily_returns AS (
    SELECT
        date,
        company_id,
        close,
        previous_close,
        ROUND((close - previous_close) / previous_close * 100, 2) AS daily_return_pct    -- DAILY RETURN --
    FROM previous_close_price
    WHERE previous_close IS NOT NULL
)
SELECT 
    company_id,
    STDDEV(daily_return_pct) AS volatility          -- VOLATILITY --
FROM daily_returns
GROUP BY company_id;

# SECTOR & COMPANY wise return %
SELECT sector, company_name, sum(return_pct) AS return_pct
FROM stocks 
GROUP BY sector, company_name 
ORDER BY return_pct DESC;

# PORTFOLIO VALUE
SELECT sum(quantity * current_price) AS portfolio_value
FROM stocks;

# PORTFOLIO WISE PROFIT AND RETURN %
SELECT portfolio_id , 
		concat(round((sum(realized_profit)/1000000),2)," M") AS Realized_profit, 
		concat(round(sum(return_pct),2)," %") AS return_pct
FROM fact_trade_pnl_kpi
GROUP BY portfolio_id
ORDER BY realized_profit DESC;


# WIN RATE
SELECT concat(((sum(win_flag)/count(*))*100)," %") AS Win_Rate
FROM fact_trade_pnl_kpi;

# TRADER WISE PROFIT AND RETURN %
SELECT trader_id , 
		concat(round((sum(realized_profit)/1000000),2)," M") AS Realized_profit, 
		concat(round(sum(return_pct),2)," %") AS return_pct
FROM fact_trade_pnl_kpi
GROUP BY trader_id
ORDER BY realized_profit DESC;
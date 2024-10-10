select *
from aapl_us
;

-- 1. Stock Price Trends Analysis
-- Write queries to find the monthly average of open, high, low, and close prices.
SELECT 
    YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
    MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) AS Month,
    AVG(Open) AS Avg_Open,
    AVG(High) AS Avg_High,
    AVG(Low) AS Avg_Low,
    AVG(Close) AS Avg_Close
FROM stock_data
GROUP BY Year, Month
ORDER BY Year, Month;

-- comparing yearly stock performances

-- 2. Volume and Price Correlation
-- 2.1. calculating daily price percentage change

WITH daily_changes AS (
    SELECT 
        Date,
        Close,
        LAG(Close) OVER (ORDER BY Date) AS Previous_Close,
        Volume,
        ((Close - LAG(Close) OVER (ORDER BY Date)) / LAG(Close) OVER (ORDER BY Date)) 
        * 100 AS Price_Change_Percentage
    FROM aapl_us
)
SELECT 
    Date,
    Close,
    Previous_Close,
    Volume,
    Price_Change_Percentage
FROM daily_changes
WHERE Previous_Close IS NOT NULL
ORDER BY Date;

-- Calculating the Correlation between Volume and Price Change


WITH daily_changes AS (
    SELECT 
        Date,
        Volume,
        ((Close - LAG(Close) OVER (ORDER BY Date)) / LAG(Close) OVER (ORDER BY Date)) 
        * 100 AS Price_Change_Percentage
    FROM aapl_us
)
SELECT 
    COUNT(*) AS n,
    SUM(Volume) AS sum_volume,
    SUM(Price_Change_Percentage) AS sum_price_change,
    SUM(Volume * Price_Change_Percentage) AS sum_product,
    SUM(Volume * Volume) AS sum_volume_squared,
    SUM(Price_Change_Percentage * Price_Change_Percentage) AS sum_price_change_squared
FROM daily_changes
WHERE Price_Change_Percentage IS NOT NULL;	


-- top 10 highest and lowest closing prices

SELECT Date, Close
FROM aapl_us
ORDER BY Close DESC
LIMIT 10;

SELECT Date, Close
FROM aapl_us
ORDER BY Close ASC
LIMIT 10;

 -- Cross-reference the volume on those days to see if unusual trading patterns occurred.
 
SELECT AVG(Volume) AS Avg_Volume -- making for the average volume
FROM aapl_us
;

WITH top_high AS (
    SELECT Date, Close, Volume
    FROM aapl_us
    ORDER BY Close DESC
    LIMIT 10
), 
top_low AS (
    SELECT Date, Close, Volume
    FROM aapl_us
    ORDER BY Close ASC
    LIMIT 10
)
SELECT * FROM (
    SELECT 'Highest' AS Price_Type, Date, Close, Volume FROM top_high
    UNION
    SELECT 'Lowest' AS Price_Type, Date, Close, Volume FROM top_low
) AS extremes;


-- Moving Averages Calculation
-- 1. 7-Day Moving Average of Closing Prices
	
SELECT
    Date,
    Close,
    AVG(Close) OVER (
        ORDER BY Date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_7Day
FROM aapl_us
ORDER BY Moving_Avg_7Day desc;

-- 2. 30 days
SELECT
    Date,
    Close,
    AVG(Close) OVER (
        ORDER BY Date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_30Day
FROM aapl_us
ORDER BY Moving_Avg_30Day desc;

-- 3. 7&30 days
SELECT
    Date,
    Close,
    AVG(Close) OVER (
        ORDER BY Date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_7Day,
    AVG(Close) OVER (
        ORDER BY Date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_30Day
FROM aapl_us
ORDER BY Date;

-- Daily Price Change Analysis
-- 1. Write queries to calculate the daily percentage change in stock prices (based on closing prices).
SELECT
    Date,
    Close,
    LAG(Close, 1) OVER (ORDER BY Date) AS Close_Yesterday,
    ((Close - LAG(Close, 1) OVER (ORDER BY Date)) / LAG(Close, 1) 
    OVER (ORDER BY Date)) * 100 AS Percent_Change
FROM aapl_us
ORDER BY Date;

-- 2. Identifying the most volatile days with the largest price swings

SELECT
    Date,
    High,
    Low,
    (High - Low) AS Price_Swing
FROM aapl_us
ORDER BY Price_Swing DESC
LIMIT 10;



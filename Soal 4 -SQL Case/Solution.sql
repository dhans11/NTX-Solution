-- Create table with specified data types
CREATE TABLE IF NOT EXISTS ecommerce_session_bigquery (
    fullVisitorId VARCHAR,
    channelGrouping VARCHAR,
    country VARCHAR,
    totalTransactionRevenue FLOAT,
    transactions INTEGER,
    timeOnSite INTEGER,
    pageviews INTEGER,
    sessionQualityDim INTEGER,
    productRefundAmount FLOAT,
    productQuantity INTEGER,
    productRevenue FLOAT,
    v2ProductName VARCHAR
);

-- --------------------------------------------------
-- CASE 1: Top 5 countries by revenue for each channel grouping
-- --------------------------------------------------
WITH ranked_data AS (
    SELECT
        channelGrouping,
        country,
        SUM(totalTransactionRevenue) AS totalRevenue,
        ROW_NUMBER() OVER (PARTITION BY channelGrouping ORDER BY SUM(totalTransactionRevenue) DESC) AS rank
    FROM ecommerce_session_bigquery
    GROUP BY channelGrouping, country
)
SELECT
    channelGrouping,
    country,
    totalRevenue
FROM ranked_data
WHERE rank <= 5
ORDER BY channelGrouping, rank;

-- --------------------------------------------------
-- CASE 2: Users spending above average time on site but viewing fewer pages
-- --------------------------------------------------
WITH UserMetrics AS (
    SELECT
        fullVisitorId,
        AVG(timeOnSite) AS avgTimeOnSite,
        AVG(pageviews) AS avgPageviews,
        AVG(sessionQualityDim) AS avgSessionQualityDim
    FROM ecommerce_session_bigquery
    GROUP BY fullVisitorId
)
SELECT
    fullVisitorId,
    avgTimeOnSite,
    avgPageviews,
    avgSessionQualityDim
FROM UserMetrics
WHERE avgTimeOnSite > (SELECT AVG(avgTimeOnSite) FROM UserMetrics)
AND avgPageviews < (SELECT AVG(avgPageviews) FROM UserMetrics);

-- --------------------------------------------------
-- CASE 3: Product performance with refund flag
-- --------------------------------------------------
WITH ProductPerformance AS (
    SELECT
        v2ProductName AS Product,
        SUM(totalTransactionRevenue) AS TotalRevenue,
        SUM(productQuantity) AS TotalQuantitySold,
        SUM(COALESCE(productRefundAmount, 0)) AS TotalRefundAmount
    FROM ecommerce_session_bigquery
    GROUP BY v2ProductName
)
SELECT
    Product,
    TotalRevenue,
    TotalRefundAmount,
    TotalRevenue - TotalRefundAmount AS NetRevenue,
    CASE
        WHEN TotalRefundAmount > 0.1 * TotalRevenue THEN 'Flagged'
        ELSE 'Not Flagged'
    END AS RefundFlag
FROM ProductPerformance
ORDER BY NetRevenue DESC;
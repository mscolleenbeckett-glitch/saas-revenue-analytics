
-- ============================================================
-- PROJECT: SaaS Revenue Operations & Financial Analytics
-- FILE: 03_customer_segmentation.sql
-- PURPOSE: Analyze customer distribution and account status.
-- DATA: Synthetic SaaS customer records
-- ============================================================


-- ANALYSIS 1: CUSTOMER DISTRIBUTION BY SEGMENT
-- Business question:
-- How many customers belong to each market segment?

SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM customers
GROUP BY customer_type
ORDER BY total_customers DESC;


-- ANALYSIS 2: ACTIVE VS CANCELLED CUSTOMERS
-- Business question:
-- What proportion of customers are currently cancelled?

SELECT
    account_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM customers
GROUP BY account_status
ORDER BY customer_count DESC;


-- ANALYSIS 3: CANCELLATIONS BY CUSTOMER SEGMENT
-- Business question:
-- Which segments have the highest proportion
-- of accounts currently marked cancelled?

SELECT
    customer_type,
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE account_status = 'Cancelled'
    ) AS cancelled_customers,
    ROUND(
        COUNT(*) FILTER (
            WHERE account_status = 'Cancelled'
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS cancelled_percentage
FROM customers
GROUP BY customer_type
ORDER BY cancelled_percentage DESC;


-- ANALYSIS 4: CUSTOMER DISTRIBUTION BY COUNTRY
-- Business question:
-- How is the customer base distributed geographically?

SELECT
    country,
    customer_type,
    COUNT(*) AS customer_count
FROM customers
GROUP BY country, customer_type
ORDER BY country, customer_count DESC;


-- ============================================================
-- END OF CUSTOMER SEGMENTATION ANALYSIS
-- ============================================================


-- ============================================================
-- PROJECT: SaaS Revenue Operations & Financial Analytics
-- FILE: 04_subscription_revenue.sql
-- PURPOSE: Analyze SaaS recurring revenue and subscriptions.
-- DATA: Synthetic SaaS subscription records
-- ============================================================


-- ANALYSIS 1: ACTIVE MONTHLY AND ANNUAL RECURRING REVENUE
-- Business question:
-- What is the current MRR and annualized run-rate ARR?

SELECT
    COUNT(*) AS active_subscriptions,
    SUM(monthly_recurring_revenue) AS total_mrr,
    SUM(monthly_recurring_revenue) * 12 AS annualized_arr
FROM subscriptions
WHERE subscription_status = 'Active';


-- ANALYSIS 2: RECURRING REVENUE BY CUSTOMER SEGMENT
-- Business question:
-- Which customer segments contribute the most MRR?

SELECT
    c.customer_type,
    COUNT(s.subscription_id) AS active_subscriptions,
    SUM(s.monthly_recurring_revenue) AS total_mrr,
    ROUND(
        SUM(s.monthly_recurring_revenue) * 100.0
        / NULLIF(
            SUM(SUM(s.monthly_recurring_revenue)) OVER (),
            0
        ),
        2
    ) AS percentage_of_mrr
FROM subscriptions s
JOIN customers c
    ON s.customer_id = c.customer_id
WHERE s.subscription_status = 'Active'
GROUP BY c.customer_type
ORDER BY total_mrr DESC;


-- ANALYSIS 3: REVENUE BY BILLING FREQUENCY
-- Business question:
-- How much active MRR comes from monthly vs annual billing?

SELECT
    billing_frequency,
    COUNT(*) AS active_subscriptions,
    SUM(monthly_recurring_revenue) AS total_mrr,
    SUM(monthly_recurring_revenue) * 12 AS annualized_arr
FROM subscriptions
WHERE subscription_status = 'Active'
GROUP BY billing_frequency
ORDER BY total_mrr DESC;


-- ANALYSIS 4: CANCELLED SUBSCRIPTION REVENUE
-- Business question:
-- How much normalized monthly revenue is associated
-- with subscriptions currently marked cancelled?

SELECT
    c.customer_type,
    COUNT(*) AS cancelled_subscriptions,
    SUM(s.monthly_recurring_revenue)
        AS cancelled_subscription_mrr
FROM subscriptions s
JOIN customers c
    ON s.customer_id = c.customer_id
WHERE s.subscription_status = 'Cancelled'
GROUP BY c.customer_type
ORDER BY cancelled_subscription_mrr DESC;


-- ============================================================
-- END OF SUBSCRIPTION REVENUE ANALYSIS
-- ============================================================

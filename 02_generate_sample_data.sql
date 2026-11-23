
-- ============================================================
-- PROJECT: SaaS Revenue Operations & Financial Analytics
-- FILE: 02_generate_sample_data.sql
-- DATABASE: PostgreSQL
--
-- PURPOSE:
-- Generate synthetic SaaS financial data for SQL analysis.
--
-- DATASET:
-- 500 Customers
-- 700 Subscriptions
-- 2,500 Invoices
-- 2,000 Payments
--
-- IMPORTANT:
-- Run only after 01_create_tables.sql on an empty database.
-- All customer and transaction data is fictional.
-- ============================================================


-- ============================================================
-- 1. GENERATE CUSTOMERS
-- ============================================================

INSERT INTO customers (
    customer_id,
    customer_name,
    customer_type,
    country,
    account_status,
    created_date
)
SELECT
    id,
    'Customer ' || LPAD(id::TEXT, 4, '0'),
    CASE
        WHEN id % 5 = 0 THEN 'Enterprise'
        WHEN id % 3 = 0 THEN 'Mid-Market'
        ELSE 'SMB'
    END,
    CASE
        WHEN id % 4 = 0 THEN 'Canada'
        ELSE 'United States'
    END,
    CASE
        WHEN id % 10 = 0 THEN 'Cancelled'
        ELSE 'Active'
    END,
    DATE '2023-01-01' + (id % 730)
FROM generate_series(1, 500) AS id;


-- ============================================================
-- 2. GENERATE SUBSCRIPTIONS
-- ============================================================

INSERT INTO subscriptions (
    subscription_id,
    customer_id,
    subscription_start_date,
    subscription_end_date,
    billing_frequency,
    monthly_recurring_revenue,
    subscription_status
)
SELECT
    id,
    ((id - 1) % 500) + 1,
    DATE '2024-01-01' + (id % 365),
    CASE
        WHEN id % 10 = 0
            THEN DATE '2025-12-31'
        ELSE NULL
    END,
    CASE
        WHEN id % 3 = 0 THEN 'Annual'
        ELSE 'Monthly'
    END,
    CASE
        WHEN id % 5 = 0 THEN 1500.00
        WHEN id % 3 = 0 THEN 750.00
        ELSE 250.00
    END,
    CASE
        WHEN id % 10 = 0 THEN 'Cancelled'
        ELSE 'Active'
    END
FROM generate_series(1, 700) AS id;


-- ============================================================
-- 3. GENERATE INVOICES
-- ============================================================
-- Join subscriptions to ensure that invoice customer IDs
-- match the customers who own those subscriptions.

INSERT INTO invoices (
    invoice_id,
    customer_id,
    subscription_id,
    invoice_date,
    due_date,
    invoice_amount,
    invoice_status
)
SELECT
    gs.id,
    s.customer_id,
    s.subscription_id,
    DATE '2025-01-01' + (gs.id % 600),
    DATE '2025-01-01' + (gs.id % 600) + 30,
    CASE
        WHEN gs.id % 5 = 0 THEN 1500.00
        WHEN gs.id % 3 = 0 THEN 750.00
        ELSE 250.00
    END,
    CASE
        WHEN gs.id % 10 = 0 THEN 'Overdue'
        WHEN gs.id % 4 = 0 THEN 'Paid'
        ELSE 'Open'
    END
FROM generate_series(1, 2500) AS gs(id)
JOIN subscriptions s
    ON s.subscription_id = ((gs.id - 1) % 700) + 1;


-- ============================================================
-- 4. GENERATE PAYMENTS
-- ============================================================
-- Simulates completed, pending, and failed payments.
-- Some payments are partially applied.
-- Some have no invoice reference (unapplied payments).

INSERT INTO payments (
    payment_id,
    customer_id,
    invoice_id,
    payment_date,
    payment_amount,
    payment_method,
    payment_status
)
SELECT
    gs.id,
    i.customer_id,
    CASE
        WHEN gs.id % 20 = 0 THEN NULL
        ELSE i.invoice_id
    END,
    i.invoice_date + (gs.id % 45),
    CASE
        WHEN gs.id % 7 = 0
            THEN ROUND(i.invoice_amount * 0.5, 2)
        ELSE i.invoice_amount
    END,
    CASE
        WHEN gs.id % 3 = 0 THEN 'Credit Card'
        WHEN gs.id % 3 = 1 THEN 'ACH'
        ELSE 'Wire'
    END,
    CASE
        WHEN gs.id % 15 = 0 THEN 'Failed'
        WHEN gs.id % 11 = 0 THEN 'Pending'
        ELSE 'Completed'
    END
FROM generate_series(1, 2000) AS gs(id)
JOIN invoices i
    ON i.invoice_id = gs.id;


-- ============================================================
-- 5. VERIFY RECORD COUNTS
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS records
FROM customers

UNION ALL

SELECT 'subscriptions', COUNT(*)
FROM subscriptions

UNION ALL

SELECT 'invoices', COUNT(*)
FROM invoices

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

ORDER BY table_name;


-- ============================================================
-- END OF SYNTHETIC DATA GENERATION
-- ============================================================

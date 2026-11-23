
-- ============================================================
-- PROJECT: SaaS Revenue Operations & Financial Analytics
-- FILE: 05_payment_reconciliation.sql
-- PURPOSE: Identify payment and invoice discrepancies
-- DATA: Synthetic SaaS financial transactions
-- ============================================================


-- ANALYSIS 1: OUTSTANDING INVOICE BALANCES
-- Business question:
-- Which invoices have unpaid balances after
-- accounting for completed payments?

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM payments
    WHERE payment_status = 'Completed'
      AND invoice_id IS NOT NULL
    GROUP BY invoice_id
)

SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_amount,
    COALESCE(p.total_paid, 0) AS total_paid,
    i.invoice_amount
        - COALESCE(p.total_paid, 0) AS outstanding_balance,
    i.invoice_status
FROM invoices i
LEFT JOIN payment_summary p
    ON i.invoice_id = p.invoice_id
WHERE i.invoice_amount
    - COALESCE(p.total_paid, 0) > 0
ORDER BY outstanding_balance DESC;


-- ANALYSIS 2: PAYMENTS WITHOUT INVOICE REFERENCES
-- Business question:
-- Are there payments that cannot be matched
-- to an invoice?

SELECT
    payment_id,
    customer_id,
    payment_date,
    payment_amount,
    payment_method,
    payment_status
FROM payments
WHERE invoice_id IS NULL
ORDER BY payment_date DESC;


-- ANALYSIS 3: FAILED AND PENDING PAYMENTS
-- Business question:
-- Which payments require investigation or follow-up?

SELECT
    payment_status,
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(payment_amount) AS transaction_amount
FROM payments
WHERE payment_status IN ('Failed', 'Pending')
GROUP BY payment_status, payment_method
ORDER BY transaction_amount DESC;


-- ANALYSIS 4: PAID INVOICES WITH OUTSTANDING BALANCES
-- Business question:
-- Are any invoices marked Paid despite
-- having an outstanding balance?

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM payments
    WHERE payment_status = 'Completed'
      AND invoice_id IS NOT NULL
    GROUP BY invoice_id
)

SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_amount,
    COALESCE(p.total_paid, 0) AS total_paid,
    i.invoice_amount
        - COALESCE(p.total_paid, 0) AS outstanding_balance
FROM invoices i
LEFT JOIN payment_summary p
    ON i.invoice_id = p.invoice_id
WHERE i.invoice_status = 'Paid'
  AND i.invoice_amount
      - COALESCE(p.total_paid, 0) > 0
ORDER BY outstanding_balance DESC;


-- ANALYSIS 5: PAYMENT OVERAPPLICATION
-- Business question:
-- Which invoices have more completed payments
-- applied than their invoiced amount?

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM payments
    WHERE payment_status = 'Completed'
      AND invoice_id IS NOT NULL
    GROUP BY invoice_id
)

SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_amount,
    p.total_paid,
    p.total_paid - i.invoice_amount AS overapplied_amount
FROM invoices i
JOIN payment_summary p
    ON i.invoice_id = p.invoice_id
WHERE p.total_paid > i.invoice_amount
ORDER BY overapplied_amount DESC;


-- ============================================================
-- END OF PAYMENT RECONCILIATION ANALYSIS
-- ============================================================


-- ============================================================
-- PROJECT: SaaS Revenue Operations & Financial Analytics
-- FILE: 01_create_tables.sql
-- DATABASE: PostgreSQL
-- DESCRIPTION:
-- Creates the relational database structure for analyzing
-- SaaS customers, subscriptions, invoices, and payments.
--
-- All data used in this project is synthetic.
-- ============================================================

-- TABLE 1: CUSTOMERS
-- Stores customer account and segmentation information.

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_type VARCHAR(50),
    country VARCHAR(50),
    account_status VARCHAR(30),
    created_date DATE
);

-- TABLE 2: SUBSCRIPTIONS
-- Stores subscription contracts and recurring revenue.
-- Each subscription belongs to one customer.

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    subscription_start_date DATE,
    subscription_end_date DATE,
    billing_frequency VARCHAR(20),
    monthly_recurring_revenue NUMERIC(12,2),
    subscription_status VARCHAR(30),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- TABLE 3: INVOICES
-- Stores billing transactions and due dates.
-- Each invoice references a customer and optionally
-- a subscription.

CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    subscription_id INTEGER,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount NUMERIC(12,2) NOT NULL,
    invoice_status VARCHAR(30),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
);

-- TABLE 4: PAYMENTS
-- Stores payment transactions and their statuses.
-- An invoice reference may be NULL for unapplied payments.

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    invoice_id INTEGER,
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (invoice_id)
        REFERENCES invoices(invoice_id)
);

-- ============================================================
-- END OF DATABASE SCHEMA
-- ============================================================

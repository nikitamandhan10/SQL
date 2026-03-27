'''
You work as a data analyst for an e-commerce platform. The sales team needs to understand the net revenue performance of Product ID 'PROD-2891' in the US market for 
purchases made during a recent two-week period. The dataset contains purchases and refunds. Refunds link to their original purchase via the original_transaction_id field.

Calculate daily net revenue for April 15-28, 2025. For each purchase date, sum all purchases from that day plus all refunds linked to those purchases 
(regardless of when the refund occurred). Include only completed transactions. Show zero for days with no activity. Return the transaction date and the calculated daily net revenue.

Table
product_sales
amount: double precision
country: text
original_transaction_id: text
product_id: text
status:text
transaction_date: date
transaction_id: text
type: text
'''
WITH cte AS (
    SELECT
        p.transaction_date,
        SUM(p.amount + COALESCE(r.amount, 0)) AS daily_net_revenue
    FROM product_sales AS p LEFT JOIN product_sales AS r
        ON
            p.transaction_id = r.original_transaction_id
            AND r.status = 'completed' AND r.type = 'refund'
    WHERE
        p.status = 'completed' AND p.type = 'purchase'
        AND p.transaction_date BETWEEN '2025-04-15' AND '2025-04-28'
        AND p.product_id = 'PROD-2891' AND p.country = 'US'
    GROUP BY p.transaction_date
),

all_dates AS (SELECT GENERATE_SERIES('2025-04-15', '2025-04-28', INTERVAL '1 day')::DATE AS transaction_date)

SELECT
    a.transaction_date,
    COALESCE(daily_net_revenue, 0) AS daily_net_revenue
FROM all_dates AS a LEFT JOIN cte ON a.transaction_date = cte.transaction_date

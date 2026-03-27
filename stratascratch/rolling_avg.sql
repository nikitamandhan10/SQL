'''
Find the 3-month rolling average of total revenue from purchases given a table with users, their purchase amount, and date purchased. 
Do not include returns which are represented by negative purchase values. Output the year-month (YYYY-MM) and 3-month rolling average of revenue, sorted from earliest month to latest month.

A 3-month rolling average is defined by calculating the average total revenue from all user purchases for the current month and previous two months. 
The first two months will not be a true 3-month rolling average since we are not given data from last year. Assume each month has at least one purchase.

amazon_purchases
created_at: date
purchase_amt: bigint
user_id: bigint
'''


-- with monthly_revenue as 
-- (select date_trunc('month', created_at) as month,
-- sum(purchase_amt) as total_revenue
-- from amazon_purchases
-- WHERE purchase_amt > 0
-- group by date_trunc('month', created_at))

-- select to_char(month, 'yyyy-mm') as year_mth,
-- round(avg(total_revenue) over(order by month rows between 2 preceding and current row),2) as rolling_avg_3m
-- from monthly_revenue


-- Where some months might be missing
WITH min_max_mth AS (
    SELECT 
        DATE_TRUNC('month', MIN(created_at)) AS min_month,
        DATE_TRUNC('month', MAX(created_at)) AS max_month
    FROM amazon_purchases
),

all_months AS (
    SELECT GENERATE_SERIES(min_month, max_month, INTERVAL '1 month') AS month
    FROM min_max_mth
),

monthly_revenue_cal AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        SUM(purchase_amt) AS total_rev
    FROM amazon_purchases
    WHERE purchase_amt > 0
    GROUP BY DATE_TRUNC('month', created_at)
)

SELECT 
    TO_CHAR(a.month, 'YYYY-MM') AS month,
    AVG(COALESCE(total_rev,0)) OVER (
        ORDER BY a.month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_3m
FROM all_months a
LEFT JOIN monthly_revenue_cal m USING(month)
ORDER BY a.month;

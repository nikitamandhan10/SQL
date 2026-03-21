'''
Identify users who started a session and placed an order on the same day.
For these users, return the total number of orders placed on that day and the total order value for that day.
Your output should include the user_id, the session_date, the total number of orders, and the total order value for that day.

Tables
sessions
session_date: date 
session_id: bigint
user_id: bigint

order_summary
order_date: date
order_id: bigint
order_value: bigint
user_id: bigint
'''

with cte as
(select user_id, min(session_date) as session_date
from sessions
group by user_id)

select c.user_id, session_date, count(order_id) as total_orders,
sum(order_value) as total_order_value
from cte c join order_summary o
on c.user_id = o.user_id and c.session_date = o.order_date
group by c.user_id, session_date

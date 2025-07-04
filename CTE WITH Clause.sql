-- Single CTE : Calculate department averages
WITH dept_averages AS (
SELECT department , AVG ( salary ) AS avg_salary
FROM employees
GROUP BY department
)
SELECT e . employee_id , e . first_name , e . last_name , e . salary ,
da . avg_salary ,
CASE
WHEN e . salary > da . avg_salary THEN ’ Above Average ’
ELSE ’ Below Average ’
END AS salary_status
FROM employees e
JOIN dept_averages da ON e . department = da . department ;
-- Multiple CTEs : Complex sales analysis
WITH monthly_sales AS (
SELECT
YEAR ( order_date ) AS year ,
MONTH ( order_date ) AS month ,
SUM ( total_amount ) AS monthly_total
FROM orders
GROUP BY YEAR ( order_date ) , MONTH ( order_date )
) ,
yearly_totals AS (
SELECT year , SUM ( monthly_total ) AS yearly_total
FROM monthly_sales
GROUP BY year
) ,
growth_analysis AS (
SELECT
ms . year , ms . month , ms . monthly_total ,
yt . yearly_total ,
ROUND (( ms . monthly_total / yt . yearly_total ) * 100 , 2) AS
pct_of_year
FROM monthly_sales ms
JOIN yearly_totals yt ON ms . year = yt . year
)
SELECT * FROM growth_analysis
ORDER BY year , month ;
-- CTE with explicit column naming
WITH top_customers ( customer_name , total_orders , total_spent ) AS
(
SELECT c . customer_name ,
COUNT ( o . order_id ) ,
SUM ( o . total_amount )
FROM customers c
JOIN orders o ON c . customer_id = o . customer_id
GROUP BY c . customer_id , c . customer_name
HAVING COUNT ( o . order_id ) >= 5
)
SELECT customer_name , total_orders , total_spent ,
RANK () OVER ( ORDER BY total_spent DESC ) AS spending_rank
FROM top_customers ;
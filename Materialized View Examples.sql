-- Sales summary materialized view for reporting
CREATE MATERIALIZED VIEW mv_monthly_sales_summary AS
SELECT
YEAR ( order_date ) AS sales_year ,
MONTH ( order_date ) AS sales_month ,
product_category ,
region ,
COUNT (*) AS order_count ,
SUM ( order_amount ) AS total_sales ,
AVG ( order_amount ) AS average_order_value ,
COUNT ( DISTINCT customer_id ) AS unique_customers
FROM orders o
JOIN products p ON o . product_id = p . product_id
JOIN customers c ON o . customer_id = c . customer_id
WHERE order_date >= DATEADD ( YEAR , -2 , GETDATE () )
GROUP BY YEAR ( order_date ) , MONTH ( order_date ) , product_category ,
region ;
-- Employee performance materialized view
CREATE MATERIALIZED VIEW mv_employee_performance_summary AS
SELECT
e . department_id ,
d . department_name ,
COUNT ( e . employee_id ) AS total_employees ,
AVG ( e . salary ) AS avg_salary ,
AVG ( pr . performance_score ) AS avg_performance ,
COUNT ( CASE WHEN pr . performance_score >= 85 THEN 1 END ) AS
high_performers ,
COUNT ( CASE WHEN e . hire_date >= DATEADD ( YEAR , -1 , GETDATE () )
THEN 1 END ) AS new_hires ,
SUM ( CASE WHEN e . status = ’ Active ’ THEN 1 ELSE 0 END ) AS
active_employees
FROM employees e
JOIN departments d ON e . department_id = d . department_id
LEFT JOIN performance_reviews pr ON e . employee_id = pr .
employee_id
AND pr . review_year = YEAR ( GETDATE () )
GROUP BY e . department_id , d . department_name ;
-- Complex analytical materialized view
CREATE MATERIALIZED VIEW mv_customer_lifetime_value AS
SELECT
c . customer_id ,
c . customer_name ,
c . registration_date ,
DATEDIFF ( MONTH , c . registration_date , GETDATE () ) AS
months_active ,
COUNT ( o . order_id ) AS total_orders ,
SUM ( o . order_amount ) AS total_spent ,
AVG ( o . order_amount ) AS avg_order_value ,
MAX ( o . order_date ) AS last_order_date ,
DATEDIFF ( DAY , MAX ( o . order_date ) , GETDATE () ) AS
days_since_last_order ,
SUM ( o . order_amount ) / NULLIF ( DATEDIFF ( MONTH , c .
registration_date , GETDATE () ) , 0) AS monthly_value ,
CASE
WHEN DATEDIFF ( DAY , MAX ( o . order_date ) , GETDATE () ) <= 30
THEN ’ Active ’
WHEN DATEDIFF ( DAY , MAX ( o . order_date ) , GETDATE () ) <= 90
THEN ’ At Risk ’
WHEN DATEDIFF ( DAY , MAX ( o . order_date ) , GETDATE () ) <= 180
THEN ’ Inactive ’
ELSE ’ Lost ’
END AS customer_status
FROM customers c
LEFT JOIN orders o ON c . customer_id = o . customer_id
GROUP BY c . customer_id , c . customer_name , c . registration_date ;
-- Refresh the materialized views
REFRESH MATERIALIZED VIEW mv_monthly_sales_summary ;
REFRESH MATERIALIZED VIEW mv_employee_performance_summary ;
REFRESH MATERIALIZED VIEW mv_customer_lifetime_value ;


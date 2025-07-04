-- Basic partitioning : Rank employees within each department
SELECT
department ,
employee_id , first_name , last_name , salary ,
RANK () OVER ( PARTITION BY department ORDER BY salary DESC )
AS dept_rank ,
AVG ( salary ) OVER ( PARTITION BY department ) AS
dept_avg_salary
FROM employees
ORDER BY department , dept_rank ;
-- Multiple partition columns : Rankings by department and job
title
SELECT
department , job_title ,
employee_id , first_name , last_name , salary ,
ROW_NUMBER () OVER (
PARTITION BY department , job_title
ORDER BY hire_date
) AS position_seniority
FROM employees
ORDER BY department , job_title , position_seniority ;
-- Running totals within partitions
SELECT
order_date , customer_id , order_amount ,
SUM ( order_amount ) OVER (
PARTITION BY customer_id
ORDER BY order_date
ROWS UNBOUNDED PRECEDING
) AS customer_running_total ,
COUNT (*) OVER (
PARTITION BY customer_id
ORDER BY order_date
ROWS UNBOUNDED PRECEDING
) AS customer_order_sequence
FROM orders
ORDER BY customer_id , order_date ;
-- Percentage of total within each partition
SELECT
region , product_category , sales_amount ,
sales_amount / SUM ( sales_amount ) OVER ( PARTITION BY region )
* 100 AS pct_of_region_sales ,
sales_amount / SUM ( sales_amount ) OVER ( PARTITION BY
product_category ) * 100 AS pct_of_category_sales ,
sales_amount / SUM ( sales_amount ) OVER () * 100 AS
pct_of_total_sales
FROM regional_sales
ORDER BY region , product_category ;
-- Compare with and without PARTITION BY
SELECT
department , employee_id , first_name , salary ,
-- Global ranking ( no partitioning )
RANK () OVER ( ORDER BY salary DESC ) AS global_rank ,
-- Department ranking ( with partitioning )
RANK () OVER ( PARTITION BY department ORDER BY salary DESC )
AS dept_rank ,
-- Global average vs department average
AVG ( salary ) OVER () AS company_avg ,
AVG ( salary ) OVER ( PARTITION BY department ) AS dept_avg
FROM employees
ORDER BY department , dept_rank ;
-- First and last values within partitions
SELECT
customer_id , order_date , order_amount ,
FIRST_VALUE ( order_amount ) OVER (
PARTITION BY customer_id
ORDER BY order_date
ROWS UNBOUNDED PRECEDING
) AS first_order_amount ,
LAST_VALUE ( order_amount ) OVER (
PARTITION BY customer_id
ORDER BY order_date
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS last_order_amount ,
LAG ( order_amount ) OVER (
PARTITION BY customer_id
ORDER BY order_date
) AS previous_order_amount
FROM orders
ORDER BY customer_id , order_date ;

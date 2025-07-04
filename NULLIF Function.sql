-- Prevent division by zero errors
SELECT
sales_rep_id , sales_rep_name ,
total_sales , total_calls ,
total_sales / NULLIF ( total_calls , 0) AS sales_per_call ,
total_sales / NULLIF ( working_days , 0) AS sales_per_day ,
CASE
WHEN NULLIF ( total_calls , 0) IS NULL THEN ’ No Calls Made ’
ELSE ’ Active Rep ’
END AS rep_status
FROM sales_performance
ORDER BY sales_per_call DESC NULLS LAST ;
-- Convert sentinel values to NULL for cleaner data
SELECT
employee_id , first_name , last_name ,
NULLIF ( middle_name , ’ ’) AS middle_name , -- Convert empty
strings to NULL
NULLIF ( phone_number , ’N / A ’) AS phone_number , -- Convert ’N /
A ’ to NULL
NULLIF ( salary , 0) AS salary , -- Convert zero salaries to
NULL
NULLIF ( department_code , ’ UNKNOWN ’) AS department_code --
Convert placeholder to NULL
FROM employees
WHERE NULLIF ( status , ’ INACTIVE ’) IS NOT NULL ; -- Only active
employees
-- Data cleansing and transformation
SELECT
product_id , product_name ,
COALESCE ( NULLIF ( description , ’ ’) , ’ No description available ’
) AS clean_description ,
COALESCE ( NULLIF ( category , ’ MISC ’) , ’ Uncategorized ’) AS
clean_category ,
NULLIF ( discount_percent , 0) AS actual_discount , -- Only
show real discounts
price * (1 - COALESCE ( NULLIF ( discount_percent , 0) , 0) / 100)
AS final_price
FROM products
ORDER BY final_price DESC ;
-- Aggregate calculations excluding unwanted values
SELECT
department ,
COUNT (*) AS total_employees ,
COUNT ( NULLIF ( salary , 0) ) AS employees_with_salary , --
Exclude zero salaries
AVG ( NULLIF ( salary , 0) ) AS avg_nonzero_salary , -- Average
excluding zeros
SUM ( NULLIF ( bonus , 0) ) AS total_actual_bonus , -- Sum only
real bonuses
AVG ( NULLIF ( performance_score , -1) ) AS avg_performance --
Exclude -1 ( not rated )
FROM employees
GROUP BY department
ORDER BY avg_nonzero_salary DESC ;
-- Complex data validation and cleansing
SELECT
customer_id ,
COALESCE ( NULLIF ( TRIM ( first_name ) , ’ ’) , ’ Unknown ’) AS
clean_first_name ,
COALESCE ( NULLIF ( TRIM ( last_name ) , ’ ’) , ’ Unknown ’) AS
clean_last_name ,
NULLIF ( NULLIF ( email , ’ ’) , ’ none@none . com ’) AS valid_email ,
-- Double NULLIF
CASE
WHEN NULLIF ( TRIM ( phone ) , ’ ’) IS NULL THEN ’ No Phone ’
WHEN LEN ( NULLIF ( TRIM ( phone ) , ’ ’) ) < 10 THEN ’ Invalid
Phone ’
ELSE NULLIF ( TRIM ( phone ) , ’ ’)
END AS clean_phone
FROM customers
WHERE NULLIF ( TRIM ( first_name ) , ’ ’) IS NOT NULL
OR NULLIF ( TRIM ( last_name ) , ’ ’) IS NOT NULL ;
-- Financial calculations with error prevention
SELECT
account_id , account_name ,
current_balance , previous_balance ,
current_balance - previous_balance AS balance_change ,
( current_balance - previous_balance ) / NULLIF (
previous_balance , 0) * 100 AS pct_change ,
CASE
WHEN NULLIF ( previous_balance , 0) IS NULL THEN ’ New
Account ’
WHEN current_balance > previous_balance THEN ’ Increased ’
WHEN current_balance < previous_balance THEN ’ Decreased ’
ELSE ’ No Change ’
END AS balance_trend ,
average_monthly_deposit / NULLIF ( months_active , 0) AS
avg_deposit_per_month
FROM account_summary
ORDER BY pct_change DESC NULLS LAST ;
-- Combining NULLIF with window functions

SELECT
employee_id , department , salary , bonus ,
NULLIF ( salary , 0) AS nonzero_salary ,
AVG ( NULLIF ( salary , 0) ) OVER ( PARTITION BY department ) AS
dept_avg_salary ,
salary / NULLIF ( AVG ( NULLIF ( salary , 0) ) OVER ( PARTITION BY
department ) , 0) AS salary_ratio ,
RANK () OVER ( PARTITION BY department ORDER BY NULLIF ( salary ,
0) DESC NULLS LAST ) AS salary_rank
FROM employees
WHERE NULLIF ( salary , 0) IS NOT NULL
ORDER BY department , salary_rank ;

-- Basic conditional logic with multiple criteria
SELECT
employee_id , first_name , last_name , salary , department ,
hire_date ,
CASE
WHEN salary >= 100000 AND department = ’ Executive ’ THEN
’ Senior Executive ’
WHEN salary >= 80000 AND DATEDIFF ( YEAR , hire_date ,
GETDATE () ) >= 10 THEN ’ Senior Professional ’
WHEN salary >= 60000 AND department IN ( ’ IT ’ , ’
Engineering ’) THEN ’ Technical Professional ’
WHEN salary >= 40000 THEN ’ Professional ’
WHEN salary >= 25000 THEN ’ Associate ’
ELSE ’ Entry Level ’
END AS job_level ,
CASE
WHEN salary > ( SELECT AVG ( salary ) FROM employees WHERE
department = e . department )
THEN ’ Above Department Average ’
ELSE ’ At or Below Department Average ’
END AS salary_position
FROM employees e
ORDER BY salary DESC ;
-- Complex business logic with nested conditions
SELECT
order_id , customer_id , order_amount , order_date ,
customer_type ,
CASE
WHEN customer_type = ’ VIP ’ THEN
CASE
WHEN order_amount >= 10000 THEN order_amount *
0.85 -- 15% discount
WHEN order_amount >= 5000 THEN order_amount *
0.90 -- 10% discount
ELSE order_amount * 0.95 -- 5% discount
END
WHEN customer_type = ’ Premium ’ THEN
CASE
WHEN order_amount >= 5000 THEN order_amount *
0.90 -- 10% discount
WHEN order_amount >= 2000 THEN order_amount *
0.95 -- 5% discount
ELSE order_amount -- No discount
END
WHEN DATEDIFF ( DAY , order_date , GETDATE () ) <= 30 THEN
order_amount * 0.98 -- 2% new customer discount
ELSE order_amount -- Regular price
END AS discounted_amount
FROM orders
ORDER BY order_date DESC ;
-- Using CASE in different SQL clauses
SELECT
product_id , product_name , category , price , stock_quantity ,
-- CASE in SELECT for status determination
CASE
WHEN stock_quantity = 0 THEN ’ Out of Stock ’
WHEN stock_quantity <= 10 THEN ’ Low Stock ’
WHEN stock_quantity <= 50 THEN ’ Normal Stock ’
ELSE ’ High Stock ’
END AS stock_status ,
-- CASE with aggregate functions
SUM ( CASE WHEN price > 100 THEN 1 ELSE 0 END ) OVER () AS
expensive_products_count
FROM products
-- CASE in WHERE clause
WHERE CASE
WHEN category = ’ Electronics ’ AND price > 500 THEN 1
WHEN category = ’ Clothing ’ AND price > 100 THEN 1
WHEN category = ’ Books ’ AND price > 50 THEN 1
ELSE 0
END = 1
-- CASE in ORDER BY clause
ORDER BY
CASE
WHEN category = ’ Featured ’ THEN 1
WHEN category = ’ New Arrival ’ THEN 2
WHEN category = ’ Sale ’ THEN 3
ELSE 4
END ,
price DESC ;
-- Handling NULL values and complex conditions
SELECT
customer_id , first_name , last_name , email , phone ,
last_login_date ,
CASE
WHEN last_login_date IS NULL THEN ’ Never Logged In ’
WHEN DATEDIFF ( DAY , last_login_date , GETDATE () ) <= 7 THEN
’ Active ’
WHEN DATEDIFF ( DAY , last_login_date , GETDATE () ) <= 30
THEN ’ Recent ’
WHEN DATEDIFF ( DAY , last_login_date , GETDATE () ) <= 90
THEN ’ Inactive ’
ELSE ’ Dormant ’
END AS user_status ,
CASE
WHEN email IS NOT NULL AND phone IS NOT NULL THEN ’
Complete Contact Info ’
WHEN email IS NOT NULL THEN ’ Email Only ’
WHEN phone IS NOT NULL THEN ’ Phone Only ’
ELSE ’ No Contact Info ’
END AS contact_completeness
FROM customers
ORDER BY last_login_date DESC NULLS LAST ;


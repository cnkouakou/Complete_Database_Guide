-- Find customers who have placed at least one order
SELECT c . customer_id , c . customer_name , c . email
FROM customers c
WHERE EXISTS (
SELECT 1
FROM orders o
WHERE o . customer_id = c . customer_id
) ;
-- Find products that have been ordered in the last 30 days
SELECT p . product_id , p . product_name , p . category
FROM products p
WHERE EXISTS (
SELECT 1
FROM order_items oi
JOIN orders o ON oi . order_id = o . order_id
WHERE oi . product_id = p . product_id
AND o . order_date >= DATEADD ( DAY , -30 , GETDATE () )
) ;
-- Find departments with at least one high - salary employee
SELECT DISTINCT d . department_id , d . department_name
FROM departments d
WHERE EXISTS (
SELECT 1
FROM employees e
WHERE e . department_id = d . department_id
AND e . salary > 75000
) ;
-- NOT EXISTS : Find customers who haven ’t placed orders in 2024
SELECT c . customer_id , c . customer_name
FROM customers c
WHERE NOT EXISTS (
SELECT 1
FROM orders o
WHERE o . customer_id = c . customer_id
AND YEAR ( o . order_date ) = 2024
) ;
-- Find employees earning more than their department average
SELECT e1 . employee_id , e1 . first_name , e1 . last_name , e1 .
department , e1 . salary
FROM employees e1
WHERE e1 . salary > (
SELECT AVG ( e2 . salary )
FROM employees e2
WHERE e2 . department = e1 . department
) ;
-- Find customers who have placed orders ( EXISTS )
SELECT c . customer_id , c . customer_name
FROM customers c
WHERE EXISTS (
SELECT 1
FROM orders o
WHERE o . customer_id = c . customer_id
) ;
-- Find products that have never been ordered ( NOT EXISTS )
SELECT p . product_id , p . product_name
FROM products p
WHERE NOT EXISTS (
SELECT 1
FROM order_items oi
WHERE oi . product_id = p . product_id
) ;
-- Find each customer ’s most recent order
SELECT c . customer_id , c . customer_name , o1 . order_date
FROM customers c
JOIN orders o1 ON c . customer_id = o1 . customer_id
WHERE o1 . order_date = (
SELECT MAX ( o2 . order_date )
FROM orders o2
WHERE o2 . customer_id = c . customer_id
) ;
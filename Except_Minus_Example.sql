-- Find customers who made purchases in 2023 but not in 2024
SELECT customer_id , customer_name , email
FROM customers c
JOIN orders o ON c . customer_id = o . customer_id
WHERE YEAR ( o . order_date ) = 2023
EXCEPT -- Use MINUS in Oracle
SELECT customer_id , customer_name , email
FROM customers c
JOIN orders o ON c . customer_id = o . customer_id
WHERE YEAR ( o . order_date ) = 2024
ORDER BY customer_name ;
-- MySQL alternative using LEFT JOIN
SELECT DISTINCT c1 . customer_id , c1 . customer_name , c1 . email
FROM (
SELECT customer_id , customer_name , email
FROM customers c
JOIN orders o ON c . customer_id = o . customer_id
WHERE YEAR ( o . order_date ) = 2023
) c1
LEFT JOIN (
SELECT DISTINCT customer_id
FROM customers c
JOIN orders o ON c . customer_id = o . customer_id
WHERE YEAR ( o . order_date ) = 2024
) c2 ON c1 . customer_id = c2 . customer_id
WHERE c2 . customer_id IS NULL
ORDER BY c1 . customer_name ;
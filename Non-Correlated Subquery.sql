SELECT product_id , product_name , price
FROM products
WHERE price > (
SELECT AVG ( price )
FROM products
) ;
-- Multi - row subquery with IN : Find customers from high - sales cities
SELECT customer_id , customer_name , city
FROM customers
WHERE city IN (
SELECT city
FROM sales_summary
WHERE total_sales > 100000
) ;
-- Multi - row subquery with ALL : Find products more expensive than all competitor products
SELECT product_id , product_name , price
FROM our_products
WHERE price > ALL (
SELECT price
FROM competitor_products
WHERE price IS NOT NULL
) ;
-- Subquery in FROM clause ( derived table )
SELECT avg_dept . department , avg_dept . avg_salary
FROM (
SELECT department , AVG ( salary ) AS avg_salary
FROM employees
GROUP BY department
) avg_dept
WHERE avg_dept . avg_salary > 50000;
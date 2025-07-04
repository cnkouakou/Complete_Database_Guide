-- Basic row numbering with global ordering
SELECT
ROW_NUMBER () OVER ( ORDER BY salary DESC ) AS row_num ,
employee_id , first_name , last_name , salary
FROM employees
ORDER BY row_num ;
-- Row numbering within partitions ( by department )
SELECT
ROW_NUMBER () OVER ( PARTITION BY department ORDER BY salary
DESC ) AS dept_rank ,
department , employee_id , first_name , last_name , salary
FROM employees
ORDER BY department , dept_rank ;
-- Pagination using ROW_NUMBER with CTE
WITH numbered_products AS (
SELECT
ROW_NUMBER () OVER ( ORDER BY product_name ) AS row_num ,
product_id , product_name , price , category
FROM products
)
SELECT product_id , product_name , price , category
FROM numbered_products
WHERE row_num BETWEEN 21 AND 30; -- Page 3 ( rows 21 -30)
-- Remove duplicates keeping first occurrence
WITH duplicate_removal AS (
SELECT
ROW_NUMBER () OVER ( PARTITION BY email ORDER BY
created_date ) AS row_num ,
customer_id , customer_name , email , created_date
FROM customers
)
DELETE FROM customers
WHERE customer_id IN (
SELECT customer_id
FROM duplicate_removal
WHERE row_num > 1
) ;
-- Top 3 products per category
WITH ranked_products AS (
SELECT
ROW_NUMBER () OVER ( PARTITION BY category ORDER BY
sales_amount DESC ) AS category_rank ,
product_id , product_name , category , sales_amount
FROM product_sales
)
SELECT product_id , product_name , category , sales_amount ,
category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY category , category_rank ;
-- Complex ordering with multiple columns
SELECT
ROW_NUMBER () OVER (
PARTITION BY region
ORDER BY total_sales DESC , customer_name ASC
) AS regional_rank ,
region , customer_name , total_sales , order_count
FROM customer_summary
ORDER BY region , regional_rank ;


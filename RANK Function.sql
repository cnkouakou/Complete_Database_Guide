-- Basic ranking by salary ( with gaps for ties )
SELECT
RANK () OVER ( ORDER BY salary DESC ) AS salary_rank ,
employee_id , first_name , last_name , salary
FROM employees
ORDER BY salary_rank ;
-- Ranking within partitions ( by department )
SELECT
RANK () OVER ( PARTITION BY department ORDER BY salary DESC )
AS dept_rank ,
department , employee_id , first_name , last_name , salary
FROM employees
ORDER BY department , dept_rank ;
-- Compare RANK vs ROW_NUMBER vs DENSE_RANK
SELECT
employee_id , first_name , last_name , salary ,
RANK () OVER ( ORDER BY salary DESC ) AS rank_with_gaps ,
DENSE_RANK () OVER ( ORDER BY salary DESC ) AS
dense_rank_no_gaps ,
ROW_NUMBER () OVER ( ORDER BY salary DESC ) AS
row_number_unique
FROM employees
ORDER BY salary DESC ;
-- Find top 3 ranked employees per department
WITH department_rankings AS (
SELECT
RANK () OVER ( PARTITION BY department ORDER BY
performance_score DESC ) AS dept_rank ,
department , employee_id , first_name , last_name ,
performance_score
FROM employees
)
SELECT department , employee_id , first_name , last_name ,
performance_score , dept_rank
FROM department_rankings
WHERE dept_rank <= 3
ORDER BY department , dept_rank ;
-- Product sales ranking with tied handling
SELECT
RANK () OVER ( ORDER BY total_sales DESC ) AS sales_rank ,
product_id , product_name , total_sales ,
CASE
WHEN RANK () OVER ( ORDER BY total_sales DESC ) <= 3 THEN 
'Top Performer'
WHEN RANK () OVER ( ORDER BY total_sales DESC ) <= 10 THEN
'Good Performer'
ELSE 'Average Performer'
END AS performance_category
FROM product_summary
ORDER BY sales_rank ;
-- Complex ranking with multiple ORDER BY columns
SELECT
RANK () OVER (
PARTITION BY region
ORDER BY total_sales DESC , customer_satisfaction DESC ,
years_active DESC
) AS comprehensive_rank ,
region , salesperson_name , total_sales , customer_satisfaction
, years_active
FROM sales_performance
ORDER BY region , comprehensive_rank ;
-- Demonstrate ranking gaps with tied values
SELECT
student_id , student_name , test_score ,
RANK () OVER ( ORDER BY test_score DESC ) AS rank_with_gaps ,
'Rank' + CAST ( RANK () OVER ( ORDER BY test_score DESC ) AS VARCHAR ) +
’ out of ’ + CAST ( COUNT (*) OVER () AS VARCHAR ) AS
rank_description
FROM student_scores
ORDER BY test_score DESC ;


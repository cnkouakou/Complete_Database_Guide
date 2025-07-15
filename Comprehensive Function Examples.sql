-- Scalar function for business calculations
CREATE FUNCTION fn_CalculateBonus ( @employee_id INT ,
@performance_score DECIMAL (5 ,2) )
RETURNS DECIMAL (10 ,2)
AS
BEGIN
DECLARE @bonus DECIMAL (10 ,2) = 0;
DECLARE @salary DECIMAL (10 ,2) ;
DECLARE @years_service INT ;
-- Get employee details
SELECT
@salary = salary ,
@years_service = DATEDIFF ( YEAR , hire_date , GETDATE () )
FROM employees
WHERE employee_id = @employee_id ;
-- Calculate bonus based on performance and tenure
IF @performance_score >= 90
SET @bonus = @salary * 0.15; -- 15% bonus for excellent
performance
ELSE IF @performance_score >= 80
SET @bonus = @salary * 0.10; -- 10% bonus for good
performance
ELSE IF @performance_score >= 70
SET @bonus = @salary * 0.05; -- 5% bonus for
satisfactory performance
-- Add tenure bonus
IF @years_service >= 10
SET @bonus = @bonus + ( @salary * 0.02) ; -- Additional 2%
for 10+ years
ELSE IF @years_service >= 5
SET @bonus = @bonus + ( @salary * 0.01) ; -- Additional 1%
for 5+ years
RETURN @bonus ;
END ;
-- String manipulation function
CREATE FUNCTION fn_FormatEmployeeName ( @first_name VARCHAR (50) ,
@last_name VARCHAR (50) , @format_type VARCHAR (20) )
RETURNS VARCHAR (150)
AS
BEGIN
DECLARE @formatted_name VARCHAR (150) ;
SET @format_type = UPPER ( LTRIM ( RTRIM ( @format_type ) ) ) ;
IF @format_type = ’ FULL ’
SET @formatted_name = LTRIM ( RTRIM ( @first_name ) ) + ’ ’ +
LTRIM ( RTRIM ( @last_name ) ) ;
ELSE IF @format_type = ’ LAST_FIRST ’
SET @formatted_name = LTRIM ( RTRIM ( @last_name ) ) + ’ , ’ +
LTRIM ( RTRIM ( @first_name ) ) ;
ELSE IF @format_type = ’ INITIALS ’
SET @formatted_name = LEFT ( LTRIM ( @first_name ) , 1) + ’. ’
+ LEFT ( LTRIM ( @last_name ) , 1) + ’. ’;
ELSE IF @format_type = ’ FORMAL ’
SET @formatted_name = UPPER ( LEFT ( LTRIM ( @first_name ) , 1) )
+ LOWER ( SUBSTRING ( LTRIM ( @first_name ) , 2 , LEN (
@first_name ) ) ) + ’ ’ +
UPPER ( LEFT ( LTRIM ( @last_name ) , 1) )
+ LOWER ( SUBSTRING ( LTRIM (
@last_name ) , 2 , LEN ( @last_name )
) ) ;
ELSE
SET @formatted_name = LTRIM ( RTRIM ( @first_name ) ) + ’ ’ +
LTRIM ( RTRIM ( @last_name ) ) ; -- Default to full name
RETURN @formatted_name ;
END ;
-- Date calculation function
CREATE FUNCTION fn_CalculateWorkingDays ( @start_date DATE ,
@end_date DATE )
RETURNS INT
AS BEGIN
DECLARE @working_days INT = 0;
DECLARE @current_date DATE = @start_date ;
WHILE @current_date <= @end_date
BEGIN
-- Exclude weekends ( Saturday = 7 , Sunday = 1)
IF DATEPART ( WEEKDAY , @current_date ) NOT IN (1 , 7)
BEGIN
SET @working_days = @working_days + 1;
END
SET @current_date = DATEADD ( DAY , 1 , @current_date ) ;
END
RETURN @working_days ;
END ;
-- Table - valued function for employee hierarchy
CREATE FUNCTION fn_GetEmployeeHierarchy ( @manager_id INT )
RETURNS TABLE
AS
RETURN
(
WITH employee_hierarchy AS (
-- Anchor : Start with the manager
SELECT
employee_id ,
first_name ,
last_name ,
manager_id ,
department_id ,
0 AS level ,
CAST ( first_name + ’ ’ + last_name AS VARCHAR (1000) )
AS hierarchy_path
FROM employees
WHERE employee_id = @manager_id
UNION ALL
-- Recursive : Get direct reports
SELECT
e . employee_id ,
e . first_name ,
e . last_name ,
e . manager_id ,
e . department_id ,
eh . level + 1 ,
eh . hierarchy_path + ’ -> ’ + e . first_name + ’ ’ + e .
last_name
FROM employees e
INNER JOIN employee_hierarchy eh ON e . manager_id = eh .
employee_id
WHERE eh . level < 10 -- Prevent infinite recursion
)
SELECT
employee_id ,
first_name ,
last_name ,
manager_id ,
department_id ,
level ,
hierarchy_path
FROM employee_hierarchy
) ;
-- Multi - statement table - valued function for sales analysis
CREATE FUNCTION fn_GetSalesAnalysis ( @start_date DATE , @end_date
DATE , @region VARCHAR (50) )
RETURNS @sales_analysis TABLE
(
product_id INT ,
product_name VARCHAR (100) ,
category VARCHAR (50) ,
total_sales DECIMAL (15 ,2) ,
order_count INT ,
avg_order_value DECIMAL (10 ,2) ,
sales_rank INT ,
performance_category VARCHAR (20)
)
AS
BEGIN
-- Insert base sales data
INSERT INTO @sales_analysis ( product_id , product_name ,
category , total_sales , order_count , avg_order_value )
SELECT
p . product_id ,
p . product_name ,
p . category ,
SUM ( oi . quantity * oi . unit_price ) AS total_sales ,
COUNT ( DISTINCT o . order_id ) AS order_count ,
AVG ( oi . quantity * oi . unit_price ) AS avg_order_value
FROM products p
INNER JOIN order_items oi ON p . product_id = oi . product_id
INNER JOIN orders o ON oi . order_id = o . order_id
INNER JOIN customers c ON o . customer_id = c . customer_id
WHERE o . order_date BETWEEN @start_date AND @end_date
AND ( @region IS NULL OR c . region = @region )
GROUP BY p . product_id , p . product_name , p . category ;
-- Update with ranking
UPDATE @sales_analysis
SET sales_rank = sub . rank
FROM (
SELECT
product_id ,
RANK () OVER ( ORDER BY total_sales DESC ) AS rank
FROM @sales_analysis
) sub
WHERE [ @sales_analysis ]. product_id = sub . product_id ;
-- Update performance categories
UPDATE @sales_analysis
SET performance_category =
CASE
WHEN sales_rank <= 10 THEN ’ Top Performer ’
WHEN sales_rank <= 50 THEN ’ Good Performer ’
WHEN total_sales >= 10000 THEN ’ Average Performer ’
ELSE ’ Poor Performer ’
END ;
RETURN ;
END ;
-- Complex business logic function
CREATE FUNCTION fn_CalculateEmployeeRating ( @employee_id INT )
RETURNS VARCHAR (20)
AS
BEGIN
DECLARE @rating VARCHAR (20) ;
DECLARE @performance_score DECIMAL (5 ,2) ;
DECLARE @attendance_rate DECIMAL (5 ,2) ;
DECLARE @years_service INT ;
DECLARE @training_hours INT ;
DECLARE @customer_satisfaction DECIMAL (5 ,2) ;
-- Gather employee metrics
SELECT
@performance_score = COALESCE ( pr . performance_score , 0) ,
@years_service = DATEDIFF ( YEAR , e . hire_date , GETDATE () ) ,
@training_hours = COALESCE ( t . total_hours , 0) ,
@customer_satisfaction = COALESCE ( cs . avg_rating , 0)
FROM employees e
LEFT JOIN performance_reviews pr ON e . employee_id = pr .
employee_id
AND pr . review_year = YEAR ( GETDATE () )
LEFT JOIN (
SELECT employee_id , SUM ( hours ) AS total_hours
FROM training_records
WHERE training_date >= DATEADD ( YEAR , -1 , GETDATE () )
GROUP BY employee_id
) t ON e . employee_id = t . employee_id
LEFT JOIN (
SELECT employee_id , AVG ( rating ) AS avg_rating
FROM customer_feedback
WHERE feedback_date >= DATEADD ( YEAR , -1 , GETDATE () )
GROUP BY employee_id
) cs ON e . employee_id = cs . employee_id
WHERE e . employee_id = @employee_id ;
-- Calculate attendance rate
SELECT @attendance_rate =
( CAST ( SUM ( CASE WHEN status = ’ Present ’ THEN 1 ELSE 0 END
) AS DECIMAL ) / COUNT (*) ) * 100
FROM attendance_records
WHERE employee_id = @employee_id
AND attendance_date >= DATEADD ( YEAR , -1 , GETDATE () ) ;
-- Determine overall rating based on multiple factors
DECLARE @total_score DECIMAL (10 ,2) = 0;
-- Performance score (40% weight )
SET @total_score = @total_score + ( @performance_score * 0.4)
;
-- Attendance (25% weight )
SET @total_score = @total_score + ( @attendance_rate * 0.25) ;
-- Experience bonus (15% weight )
SET @total_score = @total_score + ( CASE
WHEN @years_service >= 10 THEN 15
WHEN @years_service >= 5 THEN 10
WHEN @years_service >= 2 THEN 5
ELSE 0
END ) ;
-- Training commitment (10% weight )
SET @total_score = @total_score + ( CASE
WHEN @training_hours >= 40 THEN 10
WHEN @training_hours >= 20 THEN 7
WHEN @training_hours >= 10 THEN 5
ELSE 0
END ) ;
-- Customer satisfaction (10% weight )
SET @total_score = @total_score + ( @customer_satisfaction *
0.1) ;
-- Assign rating based on total score
SET @rating = CASE
WHEN @total_score >= 85 THEN ’ Exceptional ’
WHEN @total_score >= 75 THEN ’ Excellent ’
WHEN @total_score >= 65 THEN ’ Good ’
WHEN @total_score >= 55 THEN ’ Satisfactory ’
WHEN @total_score >= 45 THEN ’ Needs Improvement ’
ELSE ’ Unsatisfactory ’
END ;
RETURN @rating ;
END ;
-- Using the functions in queries
SELECT
employee_id ,
dbo . fn_FormatEmployeeName ( first_name , last_name , ’ FORMAL ’)
AS formatted_name ,
salary ,
dbo . fn_CalculateBonus ( employee_id , 85.5) AS calculated_bonus
,
dbo . fn_CalculateWorkingDays ( hire_date , GETDATE () ) AS
working_days_employed ,
dbo . fn_CalculateEmployeeRating ( employee_id ) AS
overall_rating
FROM employees
WHERE status = ’ Active ’
ORDER BY calculated_bonus DESC ;
-- Using table - valued functions
SELECT * FROM dbo . fn_GetEmployeeHierarchy (1001) ;
SELECT * FROM dbo . fn_GetSalesAnalysis ( ’ 2024 -01 -01 ’ , ’ 2024 -12 -31 ’
, ’ North America ’)
ORDER BY sales_rank ;
-- Function in WHERE clause
SELECT employee_id , first_name , last_name , salary
FROM employees
WHERE dbo . fn_CalculateBonus ( employee_id , 80.0) > 5000;




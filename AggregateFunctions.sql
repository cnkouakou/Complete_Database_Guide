-- Aggregate Functions in sql
-- The COUNT function returns the number of rows or non-NULL values in a column.

-- Count all rows in the table
SELECT COUNT(*) FROM employees;

-- Count non-NULL values in salary column
SELECT COUNT(salary) FROM employees;

-- Count distinct departments
SELECT COUNT(DISTINCT department) FROM employees;


-- COUNT(*) counts all rows including those with NULL values, while COUNT(column\_name) counts only non-NULL values in that column. 
-- COUNT(DISTINCT column\_name) counts unique non-NULL values.


-- The SUM function calculates the total of numeric values in a column.


-- Total salary expense
SELECT SUM(salary) FROM employees;

-- Total sales by department
SELECT department, SUM(sales_amount) 
FROM employees 
GROUP BY department;


-- The AVG function calculates the arithmetic mean of numeric values.


-- Average salary across all employees
SELECT AVG(salary) FROM employees;

-- Average age by department
SELECT department, AVG(age) AS avg_age
FROM employees 
GROUP BY department;


-- AVG automatically excludes NULL values from the calculation and returns the sum divided by the count of non-NULL values.
-- MAX returns the largest value while MIN returns the smallest value in a column.


-- Highest and lowest salaries
SELECT MAX(salary) AS highest_salary, 
       MIN(salary) AS lowest_salary 
FROM employees;

-- Latest hire date by department
SELECT department, MAX(hire_date) AS latest_hire
FROM employees 
GROUP BY department;




-- Simple view for employee information
CREATE VIEW employee_summary AS
SELECT
employee_id ,
first_name + ’ ’ + last_name AS full_name ,
department ,
salary ,
hire_date
FROM employees
WHERE status = ’ Active ’;
-- Complex view with joins and calculations
CREATE VIEW department_statistics AS
SELECT
d . department_name ,
COUNT ( e . employee_id ) AS employee_count ,
AVG ( e . salary ) AS average_salary ,
MIN ( e . salary ) AS minimum_salary ,
MAX ( e . salary ) AS maximum_salary ,
SUM ( e . salary ) AS total_salary_cost ,
AVG ( DATEDIFF ( YEAR , e . hire_date , GETDATE () ) ) AS
avg_years_service
FROM departments d
LEFT JOIN employees e ON d . department_id = e . department_id
WHERE e . status = ’ Active ’ OR e . status IS NULL
GROUP BY d . department_id , d . department_name ;
-- Security - focused view hiding sensitive data
CREATE VIEW public_employee_directory AS
SELECT
employee_id ,
first_name ,
last_name ,
department ,
job_title ,
work_phone ,
work_email
FROM employees
WHERE status = ’ Active ’
AND confidential_flag = 0;
-- View with conditional logic
CREATE VIEW employee_performance_categories AS
SELECT
employee_id ,
first_name + ’ ’ + last_name AS full_name ,
department ,
performance_score ,
CASE
WHEN performance_score >= 90 THEN ’ Excellent ’
WHEN performance_score >= 80 THEN ’ Good ’
WHEN performance_score >= 70 THEN ’ Satisfactory ’
WHEN performance_score >= 60 THEN ’ Needs Improvement ’
ELSE ’ Unsatisfactory ’
END AS performance_category ,
CASE
WHEN performance_score >= 85 THEN ’ Eligible for
Promotion ’
WHEN performance_score >= 75 THEN ’ Eligible for Raise ’
ELSE ’ Review Required ’
END AS recommendation
FROM employees
WHERE status = ’ Active ’ AND performance_score IS NOT NULL ;
-- Using the views
SELECT * FROM employee_summary WHERE department = ’ Engineering ’;
SELECT * FROM department_statistics ORDER BY average_salary DESC
;
SELECT * FROM public_employee_directory WHERE department LIKE ’%
Sales % ’;
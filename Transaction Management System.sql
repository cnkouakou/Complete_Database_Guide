-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SCENARIO : Employee Salary Adjustment with Comprehensive Audit Trail
-- Complex business transaction requiring multiple table updates
-- error handling , and rollback capabilities with detailed logging
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SETUP : Verify Initial State and Prepare for Transaction
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Check current employee information before transaction
SELECT
employee_id ,
CONCAT ( first_name , ’ ’ , last_name ) AS employee_name ,
department_id ,
salary ,
status
FROM employees
WHERE employee_id = 25 -- Target employee for salary adjustment
AND status = ’ Active ’;
-- Verify department budget availability
SELECT
d . department_name ,
d . budget ,
ds . total_salary_cost ,
( d . budget - ds . total_salary_cost ) AS available_budget
FROM departments d
JOIN dept_stats ds ON d . department_id = ds . department_id
WHERE d . department_id = (
SELECT department_id FROM employees WHERE employee_id = 25
) ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- TRANSACTION 1: Simple Salary Adjustment with Error Handling
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Disable autocommit to ensure manual transaction control
SET autocommit = 0;
-- Start the transaction
START TRANSACTION ;
-- Log transaction start for audit purposes
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
25 ,
’ TRANSACTION_START ’ ,
NOW () ,
’ Beginning salary adjustment transaction ’ ,
USER ()
) ;
-- Declare variables for current state ( MySQL doesn ’t support
DECLARE in regular SQL ,
-- but this shows the logic that would be implemented in a
stored procedure )
-- DECLARE @old_salary DECIMAL (10 ,2) ;
-- DECLARE @new_salary DECIMAL (10 ,2) ;
-- DECLARE @adjustment_percent DECIMAL (5 ,2) = 8.5;
-- Get current salary ( in a real scenario , this would be in a
variable )
-- For demonstration , we ’ ll use a subquery approach
-- Update employee salary with percentage increase
UPDATE employees
SET
salary = salary * 1.085 , -- 8.5% increase
last_modified = NOW ()
WHERE employee_id = 25
AND status = ’ Active ’;
-- Verify the update affected exactly one row
-- In a stored procedure , we would check @@ROWCOUNT or ROW_COUNT()
-- If no rows affected , this indicates an error condition
-- Record the salary change in history table
INSERT INTO salary_history (
employee_id ,
old_salary ,
new_salary ,
adjustment_percent ,
effective_date ,
approved_by ,
reason
) VALUES (
25 ,
( SELECT salary FROM employees WHERE employee_id = 25) /
1.085 , -- Calculate old salary
( SELECT salary FROM employees WHERE employee_id = 25) ,
-- New salary
8.5 ,
CURDATE () ,
1 , -- Assuming user ID 1 is the approver
’ Annual performance - based increase ’
) ;
-- Update department statistics to reflect new salary costs
UPDATE dept_stats
SET
total_salary_cost = (
SELECT SUM ( salary )
FROM employees
WHERE department_id = (
SELECT department_id FROM employees WHERE
employee_id = 25
)
AND status = ’ Active ’
) ,
average_salary = (
SELECT AVG ( salary )
FROM employees
WHERE department_id = (
SELECT department_id FROM employees WHERE
employee_id = 25
)
AND status = ’ Active ’
) ,
last_updated = NOW ()
WHERE department_id = (
SELECT department_id FROM employees WHERE employee_id = 25
-- Log successful salary update
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
old_values ,
new_values ,
details ,
changed_by
) VALUES (
25 ,
’ SALARY_UPDATE ’ ,
NOW () ,
CONCAT ( ’ Previous salary : ’ , ( SELECT salary FROM employees
WHERE employee_id = 25) / 1.085) ,
CONCAT ( ’ New salary : ’ , ( SELECT salary FROM employees WHERE
employee_id = 25) ) ,
’ Salary increased by 8.5% - performance bonus ’ ,
USER ()
) ;
-- Verify all changes are correct before committing
SELECT
’ Verification Query ’ AS check_type ,
e . employee_id ,
e . salary AS new_salary ,
sh . old_salary ,
sh . new_salary AS history_new_salary ,
sh . adjustment_percent ,
ds . total_salary_cost AS dept_total_cost
FROM employees e
JOIN salary_history sh ON e . employee_id = sh . employee_id
JOIN dept_stats ds ON e . department_id = ds . department_id
WHERE e . employee_id = 25
AND sh . salary_history_id = (
SELECT MAX ( salary_history_id ) FROM salary_history WHERE
employee_id = 25
) ;
-- If all verifications pass , commit the transaction
COMMIT ;
-- Log successful transaction completion
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
25 ,
’ TRANSACTION_COMMIT ’ ,
NOW () ,
’ Salary adjustment transaction completed successfully ’ ,
USER ()
) ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- TRANSACTION 2: Complex Multi - Employee Bonus Distribution with
Savepoints
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Start a new transaction for quarterly bonus distribution
START TRANSACTION ;
-- Create initial savepoint
SAVEPOINT bonus_distribution_start ;
-- Log the start of bonus distribution
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
NULL , -- This affects multiple employees
’ BONUS_DISTRIBUTION_START ’ ,
NOW () ,
’ Beginning quarterly bonus distribution for Q4 2024 ’ ,
USER ()
) ;
-- Phase 1: High Performers Bonus ( Savepoint before high
performer bonuses )
SAVEPOINT high_performer_bonuses ;
-- Calculate and distribute bonuses for high performers (
performance score >= 85)
-- Update employees with performance bonus
UPDATE employees e
JOIN performance_reviews pr ON e . employee_id = pr . employee_id
SET e . salary = e . salary + ( e . salary * 0.05) -- 5% bonus
WHERE pr . review_year = 2024
AND pr . performance_score >= 85
AND e . status = ’ Active ’
AND e . department_id IN (4 , 5) ; -- Engineering and Sales
departments only
-- Record bonus payments in salary history
INSERT INTO salary_history (
employee_id ,
old_salary ,
new_salary ,
adjustment_percent ,
effective_date ,
approved_by ,
reason
)
SELECT
e . employee_id ,
e . salary / 1.05 , -- Calculate original salary
e . salary , -- New salary with bonus
5.0 ,
CURDATE () ,
1 ,
’ Q4 2024 High Performance Bonus ’
FROM employees e
JOIN performance_reviews pr ON e . employee_id = pr . employee_id
WHERE pr . review_year = 2024
AND pr . performance_score >= 85
AND e . status = ’ Active ’
AND e . department_id IN (4 , 5) ;
-- Verify high performer bonus distribution
SELECT
’ High Performer Bonus Check ’ AS verification ,
COUNT (*) AS employees_affected ,
SUM ( e . salary * 0.05 / 1.05) AS total_bonus_amount
FROM employees e
JOIN performance_reviews pr ON e . employee_id = pr . employee_id
WHERE pr . review_year = 2024
AND pr . performance_score >= 85
AND e . status = ’ Active ’
AND e . department_id IN (4 , 5) ;
-- Phase 2: Department - wide merit increases ( Savepoint before
merit increases )
SAVEPOINT merit_increases ;
-- Apply 3% merit increase to all eligible employees
UPDATE employees
SET salary = salary * 1.03
WHERE status = ’ Active ’
AND hire_date <= DATE_SUB ( CURDATE () , INTERVAL 1 YEAR ) --
Employed for at least 1 year
AND employee_id NOT IN (
-- Exclude employees who already received high performer
bonus
SELECT DISTINCT e . employee_id
FROM employees e
JOIN performance_reviews pr ON e . employee_id = pr .
employee_id
WHERE pr . review_year = 2024
AND pr . performance_score >= 85
AND e . department_id IN (4 , 5)
) ;
-- Record merit increases in salary history
INSERT INTO salary_history (
employee_id ,
old_salary ,
new_salary ,
adjustment_percent ,
effective_date ,
approved_by ,
reason
)
SELECT
employee_id ,
salary / 1.03 , -- Calculate original salary
salary , -- New salary with merit increase
3.0 ,
CURDATE () ,
1 ,
’ Annual merit increase ’
FROM employees
WHERE status = ’ Active ’
AND hire_date <= DATE_SUB ( CURDATE () , INTERVAL 1 YEAR )
AND employee_id NOT IN (
SELECT DISTINCT e . employee_id
FROM employees e
JOIN performance_reviews pr ON e . employee_id = pr .
employee_id
WHERE pr . review_year = 2024
AND pr . performance_score >= 85
AND e . department_id IN (4 , 5)
) ;
-- Phase 3: Budget verification and potential rollback
SAVEPOINT budget_check ;
-- Check if total salary costs exceed department budgets
SELECT
d . department_name ,
d . budget ,
SUM ( e . salary ) AS total_salary_cost ,
( d . budget - SUM ( e . salary ) ) AS budget_variance ,
CASE
WHEN SUM ( e . salary ) > d . budget THEN ’ OVER_BUDGET ’
ELSE ’ WITHIN_BUDGET ’
END AS budget_status
FROM departments d
JOIN employees e ON d . department_id = e . department_id
WHERE e . status = ’ Active ’
GROUP BY d . department_id , d . department_name , d . budget
HAVING SUM ( e . salary ) > d . budget ;
-- Simulate budget check failure for Engineering department
-- In real scenario , this would be dynamic based on actual
budget constraints
-- If budget exceeded , rollback merit increases but keep high
performer bonuses
-- Rollback merit increases due to budget constraints
ROLLBACK TO merit_increases ;
-- Log the partial rollback
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
NULL ,
’ PARTIAL_ROLLBACK ’ ,
NOW () ,
’ Rolled back merit increases due to budget constraints -
high performer bonuses retained ’ ,
USER ()
) ;
-- Update department statistics after all salary changes
UPDATE dept_stats ds
JOIN (
SELECT
department_id ,
COUNT (*) AS emp_count ,
AVG ( salary ) AS avg_sal ,
SUM ( salary ) AS total_sal
FROM employees
WHERE status = ’ Active ’
GROUP BY department_id
) dept_summary ON ds . department_id = dept_summary . department_id
SET
ds . employee_count = dept_summary . emp_count ,
ds . average_salary = dept_summary . avg_sal ,
ds . total_salary_cost = dept_summary . total_sal ,
ds . last_updated = NOW () ;
-- Final verification before commit
SELECT
’ Final Transaction Summary ’ AS summary_type ,
COUNT ( DISTINCT sh . employee_id ) AS employees_affected ,
SUM ( sh . new_salary - sh . old_salary ) AS total_salary_increase ,
AVG ( sh . adjustment_percent ) AS avg_adjustment_percent
FROM salary_history sh
WHERE sh . effective_date = CURDATE ()
AND sh . reason LIKE ’% Q4 2024% ’;
-- Commit the entire transaction
COMMIT ;
-- Log successful completion of bonus distribution
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
NULL ,
’ BONUS_DISTRIBUTION_COMPLETE ’ ,
NOW () ,
’ Q4 2024 bonus distribution completed - high performer
bonuses applied , merit increases deferred due to budget
constraints ’ ,
USER ()
) ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- TRANSACTION 3: Error Handling and Complete Rollback Demonstration
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Start transaction that will demonstrate error handling
START TRANSACTION ;
-- Attempt to update a non - existent employee ( will cause constraint violation )
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
9999 , -- Non - existent employee ID
’ INVALID_OPERATION ’ ,
NOW () ,
’ Attempting operation on non - existent employee ’ ,
USER ()
) ;
-- This would succeed
UPDATE employees
SET salary = salary * 1.10
WHERE employee_id = 25;
-- This will fail due to foreign key constraint ( assuming proper
constraints )
INSERT INTO performance_reviews (
employee_id ,
review_year ,
performance_score ,
reviewer_id
) VALUES (
9999 , -- Non - existent employee
2024 ,
85.0 ,
1
) ;
-- Since the above INSERT would fail , rollback the entire transaction
ROLLBACK ;
-- Log the failed transaction
INSERT INTO employee_audit_log (
employee_id ,
action ,
action_date ,
details ,
changed_by
) VALUES (
NULL ,
’ TRANSACTION_ROLLBACK ’ ,
NOW () ,
’ Transaction rolled back due to constraint violation - no
changes applied ’ ,
USER ()
) ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- TRANSACTION 4: Isolation Level Demonstration
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Demonstrate different isolation levels and their effects
-- Set transaction isolation level for consistent reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
START TRANSACTION ;
-- Read employee salary at start of transaction
SELECT
employee_id ,
salary ,
’ Initial Read ’ AS read_type ,
NOW () AS read_time
FROM employees
WHERE employee_id = 25;
-- In a real scenario , another concurrent transaction might
modify this employee ’s salary here
-- With REPEATABLE READ isolation , we should see the same salary
value even if another
-- transaction commits changes during our transaction
-- Simulate delay ( in real scenario , other operations would
occur )
-- SELECT SLEEP (5) ; -- Wait 5 seconds
-- Read the same employee salary again
SELECT
employee_id ,
salary ,
’ Second Read ’ AS read_type ,
NOW () AS read_time
FROM employees
WHERE employee_id = 25;
-- The salary should be the same in both reads with REPEATABLE
READ isolation
-- even if another transaction modified it between our reads
COMMIT ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- CLEANUP AND FINAL VERIFICATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Re - enable autocommit
SET autocommit = 1;
-- Final verification of all changes
SELECT
’ Transaction Summary ’ AS report_type ,
COUNT (*) AS total_salary_changes ,
SUM ( new_salary - old_salary ) AS total_increase_amount ,
MIN ( effective_date ) AS first_change_date ,
MAX ( effective_date ) AS last_change_date
FROM salary_history
WHERE effective_date = CURDATE () ;
-- Audit log summary
SELECT
action ,
COUNT (*) AS occurrence_count ,
MIN ( action_date ) AS first_occurrence ,
MAX ( action_date ) AS last_occurrence
FROM employee_audit_log
WHERE DATE ( action_date ) = CURDATE ()
AND action LIKE ’% TRANSACTION % ’ OR action LIKE ’% BONUS % ’
GROUP BY action
ORDER BY last_occurrence ;



-- Audit trail trigger for employee changes
CREATE TRIGGER tr_employee_audit
ON employees
AFTER INSERT , UPDATE , DELETE
AS
BEGIN
SET NOCOUNT ON ;
-- Handle INSERT operations
IF EXISTS ( SELECT 1 FROM inserted ) AND NOT EXISTS ( SELECT 1
FROM deleted )
BEGIN
INSERT INTO employee_audit_log ( employee_id , action ,
action_date , old_values , new_values , changed_by )
SELECT
i . employee_id ,
’ INSERT ’ ,
GETDATE () ,
NULL ,
’ Name : ’ + i . first_name + ’ ’ + i . last_name +
’ , Department : ’ + CAST ( i . department_id AS VARCHAR )
+
’ , Salary : ’ + CAST ( i . salary AS VARCHAR ) +
’ , Status : ’ + i . status ,
SUSER_SNAME ()
FROM inserted i ;
END

-- Handle UPDATE operations
IF EXISTS ( SELECT 1 FROM inserted ) AND EXISTS ( SELECT 1 FROM
deleted )
BEGIN
INSERT INTO employee_audit_log ( employee_id , action ,
action_date , old_values , new_values , changed_by )
SELECT
i . employee_id ,
’ UPDATE ’ ,
GETDATE () ,
’ Name : ’ + d . first_name + ’ ’ + d . last_name +
’ , Department : ’ + CAST ( d . department_id AS VARCHAR )
+
’ , Salary : ’ + CAST ( d . salary AS VARCHAR ) +
’ , Status : ’ + d . status ,
’ Name : ’ + i . first_name + ’ ’ + i . last_name +
’ , Department : ’ + CAST ( i . department_id AS VARCHAR )
+
’ , Salary : ’ + CAST ( i . salary AS VARCHAR ) +
’ , Status : ’ + i . status ,
SUSER_SNAME ()
FROM inserted i
INNER JOIN deleted d ON i . employee_id = d . employee_id
WHERE i . first_name != d . first_name
OR i . last_name != d . last_name
OR i . department_id != d . department_id
OR i . salary != d . salary
OR i . status != d . status ;
END

-- Handle DELETE operations
IF EXISTS ( SELECT 1 FROM deleted ) AND NOT EXISTS ( SELECT 1
FROM inserted )
BEGIN
INSERT INTO employee_audit_log ( employee_id , action ,
action_date , old_values , new_values , changed_by )
SELECT
d . employee_id ,
’ DELETE ’ ,
GETDATE () ,
’ Name : ’ + d . first_name + ’ ’ + d . last_name +
’ , Department : ’ + CAST ( d . department_id AS VARCHAR )
+
’ , Salary : ’ + CAST ( d . salary AS VARCHAR ) +
’ , Status : ’ + d . status ,
NULL ,
SUSER_SNAME ()
FROM deleted d ;
END
END ;
-- Business rule enforcement trigger
CREATE TRIGGER tr_salary_validation
ON employees
AFTER INSERT , UPDATE
AS
BEGIN
SET NOCOUNT ON ;
-- Check for salary increases exceeding 50%
IF UPDATE ( salary )
BEGIN
IF EXISTS (
SELECT 1
FROM inserted i
INNER JOIN deleted d ON i . employee_id = d .
employee_id
WHERE i . salary > d . salary * 1.5
)
BEGIN
RAISERROR ( ’ Salary increase cannot exceed 50% without
approval ’ , 16 , 1) ;
ROLLBACK TRANSACTION ;
RETURN ;
END
END
-- Validate salary ranges by department
IF EXISTS (
SELECT 1
FROM inserted i
INNER JOIN departments dept ON i . department_id = dept .
department_id
WHERE ( dept . department_name = ’ Intern ’ AND i . salary >
40000)
OR ( dept . department_name = ’ Entry Level ’ AND i . salary
> 60000)
OR ( dept . department_name = ’ Senior ’ AND i . salary <
70000)
)
BEGIN
RAISERROR ( ’ Salary does not meet department guidelines ’ ,
16 , 1) ;
ROLLBACK TRANSACTION ;
RETURN ;
END
-- Automatically update last_modified timestamp
UPDATE employees
SET last_modified = GETDATE ()
WHERE employee_id IN ( SELECT employee_id FROM inserted ) ;
END ;
-- Cascading update trigger for department statistics
CREATE TRIGGER tr_update_department_stats
ON employees
AFTER INSERT , UPDATE , DELETE
AS
BEGIN
SET NOCOUNT ON ;
DECLARE @affected_departments TABLE ( department_id INT ) ;
-- Collect affected departments
INSERT INTO @affected_departments ( department_id )
SELECT DISTINCT department_id FROM inserted
UNION
SELECT DISTINCT department_id FROM deleted ;
-- Update department statistics
UPDATE dept_stats
SET
employee_count = (
SELECT COUNT (*)
FROM employees e
WHERE e . department_id = dept_stats . department_id
AND e . status = ’ Active ’
) ,
average_salary = (
SELECT AVG ( salary )
FROM employees e
WHERE e . department_id = dept_stats . department_id
AND e . status = ’ Active ’
) ,
total_salary_cost = (
SELECT SUM ( salary )
FROM employees e
WHERE e . department_id = dept_stats . department_id
AND e . status = ’ Active ’
) ,
last_updated = GETDATE ()
WHERE department_id IN ( SELECT department_id FROM
@affected_departments ) ;
-- Insert statistics for new departments
INSERT INTO dept_stats ( department_id , employee_count ,
average_salary , total_salary_cost , last_updated )
SELECT
ad . department_id ,
COUNT ( e . employee_id ) ,
AVG ( e . salary ) ,
SUM ( e . salary ) ,
GETDATE ()
FROM @affected_departments ad
LEFT JOIN employees e ON ad . department_id = e . department_id
AND e . status = ’ Active ’
WHERE ad . department_id NOT IN ( SELECT department_id FROM
dept_stats )
GROUP BY ad . department_id ;
END ;
-- INSTEAD OF trigger for view updates
CREATE TRIGGER tr_employee_view_update
ON vw_employee_summary
INSTEAD OF UPDATE
AS
BEGIN
SET NOCOUNT ON ;
-- Update base table through the view
UPDATE employees
SET
first_name = i . first_name ,
last_name = i . last_name ,
department_id = i . department_id ,
salary = CASE
WHEN i . salary != d . salary THEN i . salary
ELSE employees . salary
END
FROM inserted i
INNER JOIN deleted d ON i . employee_id = d . employee_id
WHERE employees . employee_id = i . employee_id ;
-- Log the update
INSERT INTO view_update_log ( view_name , updated_by ,
update_date , record_count )
VALUES ( ’ vw_employee_summary ’ , SUSER_SNAME () , GETDATE () ,
@@ROWCOUNT ) ;
END ;


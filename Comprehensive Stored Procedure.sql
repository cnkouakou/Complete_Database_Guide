-- Employee management stored procedure
CREATE PROCEDURE sp_ProcessEmployeeHire
@FirstName VARCHAR (50) ,
@LastName VARCHAR (50) ,
@DepartmentID INT ,
@Salary DECIMAL (10 ,2) ,
@HireDate DATE ,
@NewEmployeeID INT OUTPUT ,
@ErrorMessage VARCHAR (500) OUTPUT
AS
BEGIN
SET NOCOUNT ON ;
BEGIN TRY
BEGIN TRANSACTION ;
-- Validate department exists
IF NOT EXISTS ( SELECT 1 FROM departments WHERE
department_id = @DepartmentID )
BEGIN
SET @ErrorMessage = ’ Invalid department ID ’;
RETURN -1;
END
-- Validate salary range
IF @Salary < 30000 OR @Salary > 200000
BEGIN
SET @ErrorMessage = ’ Salary must be between $30 ,000
and $200 ,000 ’;
RETURN -2;
END
-- Insert new employee
INSERT INTO employees ( first_name , last_name ,
department_id , salary , hire_date , status )
VALUES ( @FirstName , @LastName , @DepartmentID , @Salary ,
@HireDate , ’ Active ’) ;
SET @NewEmployeeID = SCOPE_IDENTITY () ;
-- Create default performance review record
INSERT INTO performance_reviews ( employee_id ,
review_year , performance_score , review_date )
VALUES ( @NewEmployeeID , YEAR ( @HireDate ) , NULL , NULL ) ;
-- Log the hire event
INSERT INTO employee_audit_log ( employee_id , action ,
action_date , details )
VALUES ( @NewEmployeeID , ’ HIRE ’ , GETDATE () , ’ Employee
hired with ID ’ + CAST ( @NewEmployeeID AS VARCHAR ) ) ;
COMMIT TRANSACTION ;
SET @ErrorMessage = NULL ;
RETURN 0;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION ;
SET @ErrorMessage = ERROR_MESSAGE () ;
RETURN -99;
END CATCH
END ;
-- Salary adjustment procedure with business logic
CREATE PROCEDURE sp_ProcessSalaryAdjustment
@EmployeeID INT ,
@AdjustmentPercent DECIMAL (5 ,2) ,
@EffectiveDate DATE ,
@ApprovedBy INT ,
@Reason VARCHAR (255)
AS
BEGIN
SET NOCOUNT ON ;
DECLARE @CurrentSalary DECIMAL (10 ,2) ;
DECLARE @NewSalary DECIMAL (10 ,2) ;
DECLARE @MaxAdjustment DECIMAL (5 ,2) = 20.00; -- Maximum 20%
adjustment
BEGIN TRY
BEGIN TRANSACTION ;
-- Get current salary
SELECT @CurrentSalary = salary
FROM employees
WHERE employee_id = @EmployeeID AND status = ’ Active ’;
IF @CurrentSalary IS NULL
BEGIN
RAISERROR ( ’ Employee not found or inactive ’ , 16 , 1) ;
RETURN ;
END
-- Validate adjustment percentage
IF ABS ( @AdjustmentPercent ) > @MaxAdjustment
BEGIN
RAISERROR ( ’ Adjustment percentage cannot exceed % g %% ’
, 16 , 1 , @MaxAdjustment ) ;
RETURN ;
END
-- Calculate new salary
SET @NewSalary = @CurrentSalary * (1 +
@AdjustmentPercent / 100) ;
-- Update employee salary
UPDATE employees
SET salary = @NewSalary ,
last_salary_review = @EffectiveDate
WHERE employee_id = @EmployeeID ;
-- Log salary change
INSERT INTO salary_history ( employee_id , old_salary ,
new_salary ,
adjustment_percent ,
effective_date ,
approved_by , reason )
VALUES ( @EmployeeID , @CurrentSalary , @NewSalary ,
@AdjustmentPercent , @EffectiveDate , @ApprovedBy ,
@Reason ) ;
COMMIT TRANSACTION ;
SELECT
@EmployeeID AS employee_id ,
@CurrentSalary AS old_salary ,
@NewSalary AS new_salary ,
@AdjustmentPercent AS adjustment_percent ,
’ Success ’ AS result ;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION ;
SELECT
ERROR_NUMBER () AS error_number ,
ERROR_MESSAGE () AS error_message ,
’ Failed ’ AS result ;
END CATCH
END ;
-- Department statistics procedure
CREATE PROCEDURE sp_GetDepartmentStatistics
@DepartmentID INT = NULL ,
@IncludeInactive BIT = 0
AS
BEGIN
SET NOCOUNT ON ;
SELECT
d . department_id ,
d . department_name ,
COUNT ( e . employee_id ) AS employee_count ,

AVG ( e . salary ) AS average_salary ,
MIN ( e . salary ) AS minimum_salary ,
MAX ( e . salary ) AS maximum_salary ,
SUM ( e . salary ) AS total_salary_cost ,
AVG ( DATEDIFF ( YEAR , e . hire_date , GETDATE () ) ) AS
avg_years_service ,
COUNT ( CASE WHEN e . hire_date >= DATEADD ( YEAR , -1 , GETDATE
() ) THEN 1 END ) AS new_hires_last_year
FROM departments d
LEFT JOIN employees e ON d . department_id = e . department_id
WHERE ( @DepartmentID IS NULL OR d . department_id =
@DepartmentID )
AND ( @IncludeInactive = 1 OR e . status = ’ Active ’ OR e . status
IS NULL )
GROUP BY d . department_id , d . department_name
ORDER BY d . department_name ;
END ;
-- Execute the stored procedures
DECLARE @NewEmpID INT , @ErrorMsg VARCHAR (500) ;
EXEC sp_ProcessEmployeeHire ’ John ’ , ’ Smith ’ , 1 , 65000 , ’
2024 -01 -15 ’ , @NewEmpID OUTPUT , @ErrorMsg OUTPUT ;
SELECT @NewEmpID AS NewEmployeeID , @ErrorMsg AS ErrorMessage ;
EXEC sp_ProcessSalaryAdjustment 1001 , 5.5 , ’ 2024 -01 -01 ’ , 1 , ’
Annual performance increase ’;

EXEC sp_GetDepartmentStatistics @DepartmentID = 1 ,
@IncludeInactive = 0;

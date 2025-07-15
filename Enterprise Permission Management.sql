-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SCENARIO : EmployeesDB Permission Management
-- Implementing granular permission control for different user
types
-- with security layers and operational efficiency
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 1: CREATE USERS FOR PERMISSION TESTING
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create users representing different organizational roles
CREATE USER ’ hr_director ’@ ’ localhost ’ IDENTIFIED BY ’ HRDir2024 ! ’
;
CREATE USER ’ hr_assistant ’@ ’ localhost ’ IDENTIFIED BY ’ HRAsst2024
! ’;
CREATE USER ’ payroll_clerk ’@ ’ localhost ’ IDENTIFIED BY ’
PayClerk2024 ! ’;
CREATE USER ’ sales_manager ’@ ’ localhost ’ IDENTIFIED BY ’
SalesMgr2024 ! ’;
CREATE USER ’ sales_intern ’@ ’ localhost ’ IDENTIFIED BY ’
SalesInt2024 ! ’;
CREATE USER ’ finance_controller ’@ ’ localhost ’ IDENTIFIED BY ’
FinCtrl2024 ! ’;
CREATE USER ’ it_developer ’@ ’ localhost ’ IDENTIFIED BY ’ ITDev2024 !
’;
CREATE USER ’ external_auditor ’@ ’ 10.0.0.% ’ IDENTIFIED BY ’
ExtAudit2024 ! ’;
CREATE USER ’ reporting_service ’@ ’app - server . local ’ IDENTIFIED BY
’ ReportSvc2024 ! ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 2: IMPLEMENT LAYERED DATA ACCESS PERMISSIONS
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- HR Director : Comprehensive human resources management
-- Full access to employee data with ability to grant
permissions to HR team
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . employees TO ’
hr_director ’@ ’ localhost ’ WITH GRANT OPTION ;
GRANT SELECT , INSERT , UPDATE , DELETE ON EmployeesDB .
performance_reviews TO ’ hr_director ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . training_records TO
’ hr_director ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . time_off_requests TO
’ hr_director ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . attendance_records
TO ’ hr_director ’@ ’ localhost ’;
-- Access to all HR - related stored procedures
GRANT EXECUTE ON PROCEDURE EmployeesDB . GetEmployeeHierarchy TO ’
hr_director ’@ ’ localhost ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . ProcessSalaryAdjustment
TO ’ hr_director ’@ ’ localhost ’;
-- Read - only access to organizational structure
GRANT SELECT ON EmployeesDB . departments TO ’ hr_director ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . dept_stats TO ’ hr_director ’@ ’
localhost ’;
-- HR Assistant : Limited HR operations without salary access
-- Employee information access excluding sensitive financial
data
GRANT SELECT ( employee_id , first_name , last_name , middle_name ,
email , phone_work ,
department_id , manager_id , job_title , hire_date ,
status , address_line1 ,
address_line2 , city , state , postal_code ,
emergency_contact_name ,
emergency_contact_phone )
ON EmployeesDB . employees TO ’ hr_assistant ’@ ’ localhost ’;
-- Limited update permissions for contact information only
GRANT UPDATE ( email , phone_work , address_line1 , address_line2 ,
city , state ,
postal_code , emergency_contact_name ,
emergency_contact_phone )
ON EmployeesDB . employees TO ’ hr_assistant ’@ ’ localhost ’;
-- Training and attendance management
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . training_records TO
’ hr_assistant ’@ ’ localhost ’;
GRANT SELECT , INSERT ON EmployeesDB . attendance_records TO ’
hr_assistant ’@ ’ localhost ’;
-- Read - only access to performance reviews ( cannot modify )
GRANT SELECT ON EmployeesDB . performance_reviews TO ’ hr_assistant
’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 3: FINANCIAL DATA PERMISSIONS WITH STRICT CONTROLS
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Payroll Clerk : Specialized financial operations with audit
trail
-- Salary information access with modification capabilities
GRANT SELECT ( employee_id , first_name , last_name , department_id ,
salary )
ON EmployeesDB . employees TO ’ payroll_clerk ’@ ’ localhost ’;
-- Comprehensive salary history management
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . salary_history TO ’
payroll_clerk ’@ ’ localhost ’;
-- Ability to execute salary adjustment procedures
GRANT EXECUTE ON PROCEDURE EmployeesDB . ProcessSalaryAdjustment
TO ’ payroll_clerk ’@ ’ localhost ’;
-- Read - only access to department information for validation
GRANT SELECT ON EmployeesDB . departments TO ’ payroll_clerk ’@ ’
localhost ’;
-- Finance Controller : Executive - level financial oversight
-- Comprehensive access to all financial data with analytical
capabilities
GRANT SELECT ON EmployeesDB . employees TO ’ finance_controller ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . salary_history TO ’
finance_controller ’@ ’ localhost ’;
GRANT SELECT ON EmployeesDB . departments TO ’ finance_controller ’@
’ localhost ’;
GRANT SELECT ON EmployeesDB . dept_stats TO ’ finance_controller ’@ ’
localhost ’;
-- Customer and order financial data for business analysis
GRANT SELECT ON EmployeesDB . customers TO ’ finance_controller ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . orders TO ’ finance_controller ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . order_items TO ’ finance_controller ’@
’ localhost ’;
-- Access to financial calculation functions
GRANT EXECUTE ON FUNCTION EmployeesDB . CalculateBonus TO ’
finance_controller ’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 4: SALES TEAM PERMISSIONS WITH CUSTOMER FOCUS
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Sales Manager : Customer relationship and team management
-- Full customer and order management capabilities
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customers TO ’
sales_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . orders TO ’
sales_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . order_items TO ’
sales_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customer_feedback TO
’ sales_manager ’@ ’ localhost ’;
-- Product information for sales activities
GRANT SELECT ON EmployeesDB . products TO ’ sales_manager ’@ ’
localhost ’;
-- Limited employee contact information for team coordination
GRANT SELECT ( employee_id , first_name , last_name , email ,
phone_work , department_id , job_title )
ON EmployeesDB . employees TO ’ sales_manager ’@ ’ localhost ’;
-- Access to sales performance analytics
GRANT SELECT ON EmployeesDB . sales_performance TO ’ sales_manager ’
@ ’ localhost ’;
-- Sales Intern : Restricted access for learning and basic tasks
-- Read - only customer information ( no sensitive data )
GRANT SELECT ( customer_id , customer_name , company_name , city ,
state , region , customer_type )
ON EmployeesDB . customers TO ’ sales_intern ’@ ’ localhost ’;
-- Limited order viewing ( no financial details )
GRANT SELECT ( order_id , customer_id , order_date , order_status )
ON EmployeesDB . orders TO ’ sales_intern ’@ ’ localhost ’;
-- Product catalog access for learning
GRANT SELECT ( product_id , product_name , category , description )
ON EmployeesDB . products TO ’ sales_intern ’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 5: TECHNICAL AND OPERATIONAL PERMISSIONS
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- IT Developer : Database development and maintenance access
-- Schema modification capabilities for development
GRANT CREATE , ALTER , DROP ON EmployeesDB .* TO ’ it_developer ’@ ’
localhost ’;
-- Data access for testing and debugging
GRANT SELECT , INSERT , UPDATE , DELETE ON EmployeesDB .* TO ’
it_developer ’@ ’ localhost ’;
-- Stored procedure and function development
GRANT CREATE ROUTINE , ALTER ROUTINE ON EmployeesDB .* TO ’
it_developer ’@ ’ localhost ’;
GRANT EXECUTE ON EmployeesDB .* TO ’ it_developer ’@ ’ localhost ’;
-- Index management for performance optimization
GRANT INDEX ON EmployeesDB .* TO ’ it_developer ’@ ’ localhost ’;
-- External Auditor : Comprehensive read - only access with
restrictions
-- Full data access for audit purposes but no modification
capabilities
GRANT SELECT ON EmployeesDB . employees TO ’ external_auditor ’@ ’
10.0.0.% ’;
GRANT SELECT ON EmployeesDB . salary_history TO ’ external_auditor ’
@ ’ 10.0.0.% ’;
GRANT SELECT ON EmployeesDB . performance_reviews TO ’
external_auditor ’@ ’ 10.0.0.% ’;
GRANT SELECT ON EmployeesDB . departments TO ’ external_auditor ’@ ’
10.0.0.% ’;
GRANT SELECT ON EmployeesDB . employee_audit_log TO ’
external_auditor ’@ ’ 10.0.0.% ’;
-- Access to analytical views for audit reporting
GRANT SELECT ON EmployeesDB . department_statistics TO ’
external_auditor ’@ ’ 10.0.0.% ’;
GRANT SELECT ON EmployeesDB . employee_summary TO ’
external_auditor ’@ ’ 10.0.0.% ’;
-- Reporting Service : Automated system access with minimal
privileges
-- Read - only access to specific data needed for automated
reports
GRANT SELECT ( employee_id , first_name , last_name , department_id ,
job_title , hire_date , status )
ON EmployeesDB . employees TO ’ reporting_service ’@ ’app - server .
local ’;
GRANT SELECT ON EmployeesDB . departments TO ’ reporting_service ’@ ’
app - server . local ’;
GRANT SELECT ON EmployeesDB . dept_stats TO ’ reporting_service ’@ ’
app - server . local ’;
-- Access to pre - built analytical views only
GRANT SELECT ON EmployeesDB . department_statistics TO ’
reporting_service ’@ ’app - server . local ’;
GRANT SELECT ON EmployeesDB . sales_performance TO ’
reporting_service ’@ ’app - server . local ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 6: ADVANCED PERMISSION SCENARIOS
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Conditional Permissions : Time - based access for temporary
contractors
CREATE USER ’ temp_contractor ’@ ’ localhost ’ IDENTIFIED BY ’
TempContr2024 ! ’
PASSWORD EXPIRE INTERVAL 30 DAY ;
-- Limited project - specific access
GRANT SELECT ( employee_id , first_name , last_name , email ,
department_id )
ON EmployeesDB . employees TO ’ temp_contractor ’@ ’ localhost ’;
GRANT SELECT ON EmployeesDB . training_records TO ’ temp_contractor
’@ ’ localhost ’;
-- Cross - functional permissions : Finance user with HR oversight
responsibilities
CREATE USER ’ hr_finance_liaison ’@ ’ localhost ’ IDENTIFIED BY ’
HRFinLiaison2024 ! ’;
-- Combined permissions from both departments
GRANT SELECT ON EmployeesDB . employees TO ’ hr_finance_liaison ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . salary_history TO ’
hr_finance_liaison ’@ ’ localhost ’;
GRANT SELECT ON EmployeesDB . performance_reviews TO ’
hr_finance_liaison ’@ ’ localhost ’;
GRANT EXECUTE ON FUNCTION EmployeesDB . CalculateBonus TO ’
hr_finance_liaison ’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 7: PERMISSION DELEGATION AND MANAGEMENT
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Grant permission delegation capabilities to senior staff
-- HR Director can grant HR - related permissions to team members
GRANT SELECT ON EmployeesDB . training_records TO ’ hr_director ’@ ’
localhost ’ WITH GRANT OPTION ;
GRANT INSERT ON EmployeesDB . training_records TO ’ hr_director ’@ ’
localhost ’ WITH GRANT OPTION ;
-- Sales Manager can grant customer access to sales team
GRANT SELECT ON EmployeesDB . customers TO ’ sales_manager ’@ ’
localhost ’ WITH GRANT OPTION ;
-- Demonstrate permission delegation
-- HR Director grants training access to assistant
GRANT SELECT , INSERT ON EmployeesDB . training_records TO ’
hr_assistant ’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 8: PERMISSION MONITORING AND VERIFICATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Apply all permission changes
FLUSH PRIVILEGES ;
-- Comprehensive permission audit query
SELECT
GRANTEE as ’ User / Role ’ ,
TABLE_SCHEMA as ’ Database ’ ,
TABLE_NAME as ’ Table ’ ,
PRIVILEGE_TYPE as ’ Permission ’ ,
IS_GRANTABLE as ’ Can Grant to Others ’
FROM information_schema . TABLE_PRIVILEGES
WHERE TABLE_SCHEMA = ’ EmployeesDB ’
ORDER BY GRANTEE , TABLE_NAME , PRIVILEGE_TYPE ;
-- Column - level permission verification
SELECT
GRANTEE as ’ User / Role ’ ,
TABLE_NAME as ’ Table ’ ,
COLUMN_NAME as ’ Column ’ ,
PRIVILEGE_TYPE as ’ Permission ’
FROM information_schema . COLUMN_PRIVILEGES
WHERE TABLE_SCHEMA = ’ EmployeesDB ’
ORDER BY GRANTEE , TABLE_NAME , COLUMN_NAME ;
-- Routine - level permissions ( procedures and functions )
SELECT
GRANTEE as ’ User / Role ’ ,
ROUTINE_NAME as ’ Procedure / Function ’ ,
ROUTINE_TYPE as ’ Type ’ ,
PRIVILEGE_TYPE as ’ Permission ’
FROM information_schema . ROUTINE_PRIVILEGES
WHERE ROUTINE_SCHEMA = ’ EmployeesDB ’
ORDER BY GRANTEE , ROUTINE_NAME ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 9: SECURITY TESTING AND VALIDATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Test HR Assistant permissions ( should succeed )
-- SELECT first_name , last_name , email FROM EmployeesDB .
employees LIMIT 5;
-- Test HR Assistant trying to access salary ( should fail )
-- SELECT salary FROM EmployeesDB . employees LIMIT 1;
-- Test Sales Intern accessing customer financial data ( should
fail )
-- SELECT total_amount FROM EmployeesDB . orders LIMIT 1;
-- Test Payroll Clerk accessing non - financial employee data (
should fail )
-- SELECT emergency_contact_name FROM EmployeesDB . employees
LIMIT 1;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 10: PERMISSION LIFECYCLE MANAGEMENT
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Regular maintenance : Review and update permissions
-- Revoke outdated permissions
REVOKE INSERT ON EmployeesDB . training_records FROM ’
temp_contractor ’@ ’ localhost ’;
-- Update permissions for role changes
-- Example : HR Assistant promoted to HR Specialist
GRANT UPDATE ( salary ) ON EmployeesDB . employees TO ’ hr_assistant ’
@ ’ localhost ’;
GRANT INSERT ON EmployeesDB . performance_reviews TO ’ hr_assistant
’@ ’ localhost ’;
-- Implement permission expiration for temporary access
-- CREATE EVENT expire_temp_permissions
-- ON SCHEDULE AT ’2024 -12 -31 23:59:59 ’
-- DO REVOKE ALL PRIVILEGES ON EmployeesDB .* FROM ’
temp_contractor ’@ ’ localhost ’;
-- Document permission changes in audit log
INSERT INTO EmployeesDB . employee_audit_log
( employee_id , action , action_date , details , changed_by )
VALUES
( NULL , ’ UPDATE ’ , NOW () , ’ Permission review completed - updated
access levels ’ , USER () ) ;


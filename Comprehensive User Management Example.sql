-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SCENARIO : Setting up users for EmployeesDB
-- Company needs different access levels for various roles
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- 1. Create HR Manager user with comprehensive HR data access
CREATE USER ’ hr_manager ’@ ’ localhost ’
IDENTIFIED BY ’ SecureHR2024 ! ’
PASSWORD EXPIRE INTERVAL 90 DAY ;
-- Grant HR manager full access to employee - related tables
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . employees TO ’
hr_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . performance_reviews
TO ’ hr_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . salary_history TO ’
hr_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . training_records TO
’ hr_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . time_off_requests TO
’ hr_manager ’@ ’ localhost ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . attendance_records
TO ’ hr_manager ’@ ’ localhost ’;
-- Grant read - only access to departments for organizational
structure
GRANT SELECT ON EmployeesDB . departments TO ’ hr_manager ’@ ’
localhost ’;
-- Grant access to HR - specific views and procedures
GRANT SELECT ON EmployeesDB . employee_summary TO ’ hr_manager ’@ ’
localhost ’;
GRANT SELECT ON EmployeesDB . department_statistics TO ’ hr_manager
’@ ’ localhost ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . GetEmployeeHierarchy TO ’
hr_manager ’@ ’ localhost ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . ProcessSalaryAdjustment
TO ’ hr_manager ’@ ’ localhost ’;
-- 2. Create Sales Representative with limited customer and
order access
CREATE USER ’ sales_rep ’@ ’% ’
IDENTIFIED BY ’ Sales2024Pass ! ’
PASSWORD EXPIRE INTERVAL 180 DAY
WITH MAX_CONNECTIONS_PER_HOUR 100;
-- Grant sales rep access to customer and order management
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customers TO ’
sales_rep ’@ ’% ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . orders TO ’ sales_rep
’@ ’% ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . order_items TO ’
sales_rep ’@ ’% ’;
GRANT SELECT ON EmployeesDB . products TO ’ sales_rep ’@ ’% ’;
-- Grant limited employee information ( only contact details , no
salary )
GRANT SELECT ( employee_id , first_name , last_name , email ,
phone_work , department_id )
ON EmployeesDB . employees TO ’ sales_rep ’@ ’% ’;
-- Grant access to sales - related views
GRANT SELECT ON EmployeesDB . sales_performance TO ’ sales_rep ’@ ’% ’
;
-- Allow sales rep to provide customer feedback
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customer_feedback TO
’ sales_rep ’@ ’% ’;
-- 3. Create Read - Only Analyst user for reporting and analytics
CREATE USER ’ data_analyst ’@ ’ 10.0.% ’
IDENTIFIED BY ’ Analytics2024 ! ’
PASSWORD EXPIRE INTERVAL 120 DAY
WITH MAX_QUERIES_PER_HOUR 1000;
-- Grant comprehensive read - only access for analysis
GRANT SELECT ON EmployeesDB .* TO ’ data_analyst ’@ ’ 10.0.% ’;
-- Explicitly deny access to sensitive audit logs
REVOKE SELECT ON EmployeesDB . employee_audit_log FROM ’
data_analyst ’@ ’ 10.0.% ’;
-- Grant access to analytical functions
GRANT EXECUTE ON FUNCTION EmployeesDB . CalculateBonus TO ’
data_analyst ’@ ’ 10.0.% ’;
GRANT EXECUTE ON FUNCTION EmployeesDB . FormatEmployeeName TO ’
data_analyst ’@ ’ 10.0.% ’;
-- 4. Create IT Administrator with comprehensive system access
CREATE USER ’ db_admin ’@ ’ localhost ’
IDENTIFIED BY ’ DBAdmin2024Secure ! ’
PASSWORD EXPIRE INTERVAL 60 DAY
REQUIRE SSL ;
-- Grant full administrative privileges
GRANT ALL PRIVILEGES ON EmployeesDB .* TO ’ db_admin ’@ ’ localhost ’
WITH GRANT OPTION ;
-- Grant global privileges for database administration
GRANT CREATE USER , RELOAD , PROCESS , SHOW DATABASES ON *.* TO ’
db_admin ’@ ’ localhost ’;
-- 5. Create Application Service Account with specific
operational access
CREATE USER ’ app_service ’@ ’app - server . company . com ’
IDENTIFIED BY ’ AppService2024Complex ! ’
PASSWORD EXPIRE NEVER ;
-- Grant application the minimum required permissions
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . employees TO ’
app_service ’@ ’app - server . company . com ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customers TO ’
app_service ’@ ’app - server . company . com ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . orders TO ’
app_service ’@ ’app - server . company . com ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . order_items TO ’
app_service ’@ ’app - server . company . com ’;
GRANT SELECT ON EmployeesDB . products TO ’ app_service ’@ ’app -
server . company . com ’;
-- Grant access to application - specific stored procedures
GRANT EXECUTE ON PROCEDURE EmployeesDB . ProcessSalaryAdjustment
TO ’ app_service ’@ ’app - server . company . com ’;
-- 6. Apply all privilege changes
FLUSH PRIVILEGES ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- VERIFICATION AND MONITORING
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Show all created users and their hosts
SELECT User , Host , account_locked , password_expired
FROM mysql . user
WHERE User IN ( ’ hr_manager ’ , ’ sales_rep ’ , ’ data_analyst ’ , ’
db_admin ’ , ’ app_service ’) ;
-- Display detailed privileges for HR Manager
SHOW GRANTS FOR ’ hr_manager ’@ ’ localhost ’;
-- Display connection and query limits for sales rep
SELECT User , Host , max_connections , max_user_connections ,
max_questions
FROM mysql . user
WHERE User = ’ sales_rep ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SECURITY BEST PRACTICES IMPLEMENTATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create role - based access for better management
CREATE ROLE ’ hr_role ’ , ’ sales_role ’ , ’ analyst_role ’;
-- Grant privileges to roles instead of individual users
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . employees TO ’
hr_role ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customers TO ’
sales_role ’;
GRANT SELECT ON EmployeesDB .* TO ’ analyst_role ’;
-- Assign roles to users ( MySQL 8.0+)
GRANT ’ hr_role ’ TO ’ hr_manager ’@ ’ localhost ’;
GRANT ’ sales_role ’ TO ’ sales_rep ’@ ’% ’;
GRANT ’ analyst_role ’ TO ’ data_analyst ’@ ’ 10.0.% ’;
-- Set default roles for automatic activation
ALTER USER ’ hr_manager ’@ ’ localhost ’ DEFAULT ROLE ’ hr_role ’;
ALTER USER ’ sales_rep ’@ ’% ’ DEFAULT ROLE ’ sales_role ’;
ALTER USER ’ data_analyst ’@ ’ 10.0.% ’ DEFAULT ROLE ’ analyst_role ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- ACCOUNT MAINTENANCE AND SECURITY
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Expire passwords for security compliance
ALTER USER ’ hr_manager ’@ ’ localhost ’ PASSWORD EXPIRE ;
-- Lock accounts that are no longer needed
ALTER USER ’ old_employee ’@ ’ localhost ’ ACCOUNT LOCK ;
-- Set password validation requirements ( if validate_password
plugin is active )
-- This ensures strong passwords for all new users
SET GLOBAL validate_password . policy = MEDIUM ;

SET GLOBAL validate_password . length = 12;
SET GLOBAL validate_password . mixed_case_count = 1;
SET GLOBAL validate_password . number_count = 1;
SET GLOBAL validate_password . special_char_count = 1;


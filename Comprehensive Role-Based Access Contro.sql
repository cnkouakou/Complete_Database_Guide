-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SCENARIO : Enterprise EmployeesDB Role - Based Security System
-- Large organization needs standardized access control across
departments
-- with role hierarchy and dynamic privilege management
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 1: CREATE FOUNDATIONAL ROLES
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Base data access roles for different data sensitivity levels
CREATE ROLE ’ public_data_reader ’; -- Non - sensitive
company data
CREATE ROLE ’ confidential_data_reader ’; -- Confidential
employee data
CREATE ROLE ’ financial_data_reader ’; -- Financial and salary
data
CREATE ROLE ’ administrative_data_manager ’; -- Full
administrative access
-- Functional roles based on job responsibilities
CREATE ROLE ’ hr_specialist ’; -- Human resources
functions
CREATE ROLE ’ sales_representative ’; -- Sales and customer
management
CREATE ROLE ’ finance_analyst ’; -- Financial analysis
and reporting
CREATE ROLE ’ it_support ’; -- Technical support
functions
CREATE ROLE ’ executive_manager ’; -- Executive - level
access
-- Operational roles for specific business processes
CREATE ROLE ’ employee_onboarding ’; -- New employee setup
CREATE ROLE ’ performance_reviewer ’; -- Performance
management
CREATE ROLE ’ payroll_processor ’; -- Salary and benefits
processing
CREATE ROLE ’ training_coordinator ’; -- Training and
development
CREATE ROLE ’ customer_service ’; -- Customer interaction
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 2: ASSIGN PRIVILEGES TO BASE DATA ROLES
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Public data reader : Basic company information , no personal
data
GRANT SELECT ON EmployeesDB . departments TO ’ public_data_reader ’;
GRANT SELECT ON EmployeesDB . products TO ’ public_data_reader ’;
GRANT SELECT ( product_name , category , price ) ON EmployeesDB .
products TO ’ public_data_reader ’;
GRANT SELECT ON EmployeesDB . training_records TO ’
public_data_reader ’;
-- Confidential data reader : Employee information without
financial data
GRANT SELECT ON EmployeesDB . employees TO ’
confidential_data_reader ’;
GRANT SELECT ON EmployeesDB . performance_reviews TO ’
confidential_data_reader ’;
GRANT SELECT ON EmployeesDB . attendance_records TO ’
confidential_data_reader ’;
GRANT SELECT ON EmployeesDB . time_off_requests TO ’
confidential_data_reader ’;
GRANT SELECT ON EmployeesDB . employee_audit_log TO ’
confidential_data_reader ’;
-- However , explicitly exclude salary information from
confidential reader
REVOKE SELECT ( salary ) ON EmployeesDB . employees FROM ’
confidential_data_reader ’;
-- Financial data reader : Access to salary and financial
information
GRANT SELECT ON EmployeesDB . salary_history TO ’
financial_data_reader ’;
GRANT SELECT ( employee_id , salary ) ON EmployeesDB . employees TO ’
financial_data_reader ’;
GRANT SELECT ON EmployeesDB . orders TO ’ financial_data_reader ’;
GRANT SELECT ON EmployeesDB . order_items TO ’
financial_data_reader ’;
-- Administrative data manager : Full database access for system
management
GRANT ALL PRIVILEGES ON EmployeesDB .* TO ’
administra tive_data_manager ’ WITH GRANT OPTION ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 3: BUILD FUNCTIONAL ROLES WITH ROLE INHERITANCE
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- HR Specialist : Combines confidential data access with HR -
specific operations
GRANT ’ public_data_reader ’ TO ’ hr_specialist ’;
GRANT ’ confidential_data_reader ’ TO ’ hr_specialist ’;
-- Add HR - specific privileges
GRANT INSERT , UPDATE ON EmployeesDB . employees TO ’ hr_specialist ’
;
GRANT INSERT , UPDATE ON EmployeesDB . performance_reviews TO ’
hr_specialist ’;
GRANT INSERT , UPDATE ON EmployeesDB . training_records TO ’
hr_specialist ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . time_off_requests TO
’ hr_specialist ’;
-- Grant access to HR functions and views
GRANT SELECT ON EmployeesDB . employee_summary TO ’ hr_specialist ’;
GRANT SELECT ON EmployeesDB . department_statistics TO ’
hr_specialist ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . GetEmployeeHierarchy TO ’
hr_specialist ’;
-- Sales Representative : Customer and order management with
limited employee access
GRANT ’ public_data_reader ’ TO ’ sales_representative ’;
-- Add sales - specific privileges
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customers TO ’
sales_representative ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . orders TO ’
sales_representative ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . order_items TO ’
sales_representative ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customer_feedback TO
’ sales_representative ’;
-- Limited employee contact information only
GRANT SELECT ( employee_id , first_name , last_name , email ,
phone_work , job_title )
ON EmployeesDB . employees TO ’ sales_representative ’;
-- Access to sales performance views
GRANT SELECT ON EmployeesDB . sales_performance TO ’
sales_representative ’;
-- Finance Analyst : Comprehensive financial data access with
analysis capabilities
GRANT ’ public_data_reader ’ TO ’ finance_analyst ’;
GRANT ’ financial_data_reader ’ TO ’ finance_analyst ’;
-- Add finance - specific analysis privileges
GRANT SELECT ON EmployeesDB . dept_stats TO ’ finance_analyst ’;
GRANT EXECUTE ON FUNCTION EmployeesDB . CalculateBonus TO ’
finance_analyst ’;
GRANT EXECUTE ON FUNCTION EmployeesDB . FormatEmployeeName TO ’
finance_analyst ’;
-- IT Support : Technical access for database maintenance and
user support
GRANT ’ public_data_reader ’ TO ’ it_support ’;
-- Add IT - specific privileges
GRANT SELECT ON mysql . user TO ’ it_support ’;
GRANT PROCESS ON *.* TO ’ it_support ’;
GRANT SHOW DATABASES ON *.* TO ’ it_support ’;
-- Executive Manager : High - level access combining multiple data
types
GRANT ’ public_data_reader ’ TO ’ executive_manager ’;
GRANT ’ confidential_data_reader ’ TO ’ executive_manager ’;
GRANT ’ financial_data_reader ’ TO ’ executive_manager ’;
-- Add executive - level reporting access
GRANT SELECT ON EmployeesDB . department_statistics TO ’
executive_manager ’;
GRANT SELECT ON EmployeesDB . sales_performance TO ’
executive_manager ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . GetEmployeeHierarchy TO ’
executive_manager ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 4: CREATE SPECIALIZED OPERATIONAL ROLES
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Employee Onboarding : Specific privileges for HR onboarding
process
GRANT ’ public_data_reader ’ TO ’ employee_onboarding ’;
GRANT INSERT ON EmployeesDB . employees TO ’ employee_onboarding ’;
GRANT INSERT ON EmployeesDB . performance_reviews TO ’
employee_onboarding ’;
GRANT INSERT ON EmployeesDB . training_records TO ’
employee_onboarding ’;
-- Performance Reviewer : Limited to performance management
functions
GRANT ’ public_data_reader ’ TO ’ performance_reviewer ’;
GRANT SELECT ( employee_id , first_name , last_name , department_id ,
job_title , manager_id )
ON EmployeesDB . employees TO ’ performance_reviewer ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . performance_reviews
TO ’ performance_reviewer ’;
-- Payroll Processor : Financial operations with audit trail
GRANT ’ financial_data_reader ’ TO ’ payroll_processor ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . salary_history TO ’
payroll_processor ’;
GRANT EXECUTE ON PROCEDURE EmployeesDB . ProcessSalaryAdjustment
TO ’ payroll_processor ’;
-- Training Coordinator : Training and development management
GRANT ’ public_data_reader ’ TO ’ training_coordinator ’;
GRANT SELECT ( employee_id , first_name , last_name , department_id ,
job_title )
ON EmployeesDB . employees TO ’ training_coordinator ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . training_records TO
’ training_coordinator ’;
-- Customer Service : Customer interaction and feedback
management
GRANT SELECT ( customer_id , customer_name , email , phone , region ,
customer_type )
ON EmployeesDB . customers TO ’ customer_service ’;
GRANT SELECT ON EmployeesDB . orders TO ’ customer_service ’;
GRANT SELECT , INSERT , UPDATE ON EmployeesDB . customer_feedback TO
’ customer_service ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 5: CREATE USERS AND ASSIGN ROLES
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create users for different organizational levels
CREATE USER ’ alice_hr ’@ ’ localhost ’ IDENTIFIED BY ’ HRAlice2024 ! ’;
CREATE USER ’ bob_sales ’@ ’% ’ IDENTIFIED BY ’ SalesBob2024 ! ’;
CREATE USER ’ carol_finance ’@ ’ localhost ’ IDENTIFIED BY ’
FinanceCarol2024 ! ’;
CREATE USER ’ dave_it ’@ ’ localhost ’ IDENTIFIED BY ’ ITDave2024 ! ’;
CREATE USER ’ eve_executive ’@ ’ localhost ’ IDENTIFIED BY ’
ExecEve2024 ! ’;
-- Assign primary roles to users
GRANT ’ hr_specialist ’ TO ’ alice_hr ’@ ’ localhost ’;
GRANT ’ sales_representative ’ TO ’ bob_sales ’@ ’% ’;
GRANT ’ finance_analyst ’ TO ’ carol_finance ’@ ’ localhost ’;
GRANT ’ it_support ’ TO ’ dave_it ’@ ’ localhost ’;
GRANT ’ executive_manager ’ TO ’ eve_executive ’@ ’ localhost ’;
-- Assign additional operational roles based on responsibilities
GRANT ’ employee_onboarding ’ TO ’ alice_hr ’@ ’ localhost ’; --
HR can onboard
GRANT ’ performance_reviewer ’ TO ’ alice_hr ’@ ’ localhost ’; --
HR can review performance
GRANT ’ payroll_processor ’ TO ’ carol_finance ’@ ’ localhost ’; --
Finance can process payroll
GRANT ’ training_coordinator ’ TO ’ alice_hr ’@ ’ localhost ’; --
HR coordinates training
-- Set default roles for automatic activation
ALTER USER ’ alice_hr ’@ ’ localhost ’
DEFAULT ROLE ’ hr_specialist ’ , ’ employee_onboarding ’ , ’
performance_reviewer ’ , ’ training_coordinator ’;
ALTER USER ’ bob_sales ’@ ’% ’
DEFAULT ROLE ’ sales_representative ’;
ALTER USER ’ carol_finance ’@ ’ localhost ’
DEFAULT ROLE ’ finance_analyst ’ , ’ payroll_processor ’;
ALTER USER ’ dave_it ’@ ’ localhost ’
DEFAULT ROLE ’ it_support ’;
ALTER USER ’ eve_executive ’@ ’ localhost ’
DEFAULT ROLE ’ executive_manager ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 6: DEMONSTRATE DYNAMIC ROLE MANAGEMENT
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create temporary project roles for specific initiatives
CREATE ROLE ’ project_alpha_team ’;
CREATE ROLE ’ quarterly_audit_team ’;
-- Grant project - specific access
GRANT SELECT ON EmployeesDB .* TO ’ project_alpha_team ’;
GRANT ’ confidential_data_reader ’ TO ’ quarterly_audit_team ’;
GRANT ’ financial_data_reader ’ TO ’ quarterly_audit_team ’;
-- Temporarily assign project roles ( would be done as needed )
-- GRANT ’ project_alpha_team ’ TO ’ bob_sales ’@ ’% ’;
-- GRANT ’ quarterly_audit_team ’ TO ’ carol_finance ’@ ’ localhost ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 7: ROLE MONITORING AND ADMINISTRATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Apply all role and privilege changes
FLUSH PRIVILEGES ;
-- Verify role assignments
SELECT
User , Host ,
JSON_EXTRACT ( User_attributes , ’$ . default_roles ’) AS
default_roles
FROM mysql . user
WHERE User IN ( ’ alice_hr ’ , ’ bob_sales ’ , ’ carol_finance ’ , ’
dave_it ’ , ’ eve_executive ’) ;
-- Show role hierarchy and inheritance
SELECT
FROM_USER AS ’ Role ’ ,
TO_USER AS ’ Granted To ’
FROM mysql . role_edges
ORDER BY FROM_USER , TO_USER ;
-- Display all privileges for a specific role
SHOW GRANTS FOR ’ hr_specialist ’;
-- Show effective privileges for a user ( including inherited
from roles )
SHOW GRANTS FOR ’ alice_hr ’@ ’ localhost ’ USING ’ hr_specialist ’;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- STEP 8: SECURITY BEST PRACTICES AND MAINTENANCE
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create audit role for tracking privilege usage
CREATE ROLE ’ security_auditor ’;
GRANT SELECT ON mysql . user TO ’ security_auditor ’;
GRANT SELECT ON mysql . role_edges TO ’ security_auditor ’;
GRANT SELECT ON mysql . tables_priv TO ’ security_auditor ’;
GRANT SELECT ON mysql . columns_priv TO ’ security_auditor ’;
GRANT SELECT ON information_schema . USER_PRIVILEGES TO ’
security_auditor ’;
-- Regular maintenance : Review and clean up unused roles
-- DROP ROLE ’ project_alpha_team ’; -- Remove when project
completes
-- Implement role rotation for high - privilege operations
CREATE ROLE ’ emergency_admin ’;
GRANT ’ administrative_data_manager ’ TO ’ emergency_admin ’;
-- This role would be granted temporarily during emergencies
only
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DEMONSTRATION : DYNAMIC ROLE ACTIVATION
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Example of user session with role switching
-- ( These commands would be executed by alice_hr during her
session )
-- Check current roles
-- SELECT CURRENT_ROLE () ;
-- Activate additional role for specific task
-- SET ROLE ’ performance_reviewer ’;
-- Perform performance review tasks ...
-- Switch to payroll processing ( if she had that role )
-- SET ROLE ’ hr_specialist ’, ’ payroll_processor ’;
-- Deactivate all roles except default
-- SET ROLE DEFAULT ;

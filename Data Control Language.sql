-- Data Control Language (DCL)

-- Creating Users and Roles
-- Before granting permissions, users and roles must be created:
-- Create users
CREATE USER 'john_doe' @ 'localhost' IDENTIFIED BY 'secure_password';
CREATE USER 'jane_smith'@ '%' IDENTIFIED BY 'another_password';
-- Create roles ( MySQL 8.0+ / PostgreSQL / SQL Server )
CREATE ROLE hr_manager ;
CREATE ROLE sales_team ;
CREATE ROLE data_analyst ;

-- ===========================================================================
-- Table-Level Permissions
-- Grant SELECT permission on specific table
GRANT SELECT ON company . employees TO 'john_doe'@'localhost';
-- Grant multiple permissions on a table
GRANT SELECT , INSERT , UPDATE ON company . products
TO 'jane_smith'@'%';
-- Grant all privileges on a table
GRANT ALL PRIVILEGES ON company . customers TO hr_manager ;
-- Grant permission with GRANT OPTION ( allows user to grant to others )
GRANT SELECT ON company . sales_data TO data_analyst
WITH GRANT OPTION ;
-- ===========================================================================

-- Database-Level Permissions
-- Grant permissions on entire database
GRANT SELECT , INSERT ON company .* TO sales_team ;
-- Grant CREATE permission for new tables
GRANT CREATE ON company .* TO ’ john_doe ’@ ’ localhost ’;
-- Grant all privileges on database
GRANT ALL PRIVILEGES ON company .* TO ’ admin_user ’@ ’ localhost ’;

-- ===========================================================================
-- Column-Level Permissions
-- Grant SELECT on specific columns
GRANT SELECT ( first_name , last_name , department )
ON company . employees TO ’ hr_assistant ’@ ’ localhost ’;
-- Grant UPDATE on specific columns
GRANT UPDATE ( salary , bonus )
ON company . employees TO hr_manager ;

-- ===========================================================================
== Role-Based Permissions
-- Grant permissions to roles
GRANT SELECT , INSERT , UPDATE ON company . orders TO sales_team ;
GRANT SELECT ON company .* TO data_analyst ;
-- Assign roles to users
GRANT sales_team TO ’ jane_smith ’@ ’% ’;
GRANT hr_manager TO ’ john_doe ’@ ’ localhost ’;
GRANT data_analyst TO ’ report_user ’@ ’ localhost ’;
-- Grant one role to another role ( role hierarchy )
GRANT data_analyst TO hr_manager ;
-- ===========================================================================

-- Revoking Table Permissions
-- Revoke specific permission
REVOKE INSERT ON company . employees FROM ’ john_doe ’@ ’ localhost ’;
-- Revoke multiple permissions
REVOKE SELECT , UPDATE ON company . products
FROM ’ jane_smith ’@ ’% ’;
-- Revoke all privileges
REVOKE ALL PRIVILEGES ON company . customers FROM hr_manager ;
-- Revoke with CASCADE ( removes dependent grants )
REVOKE SELECT ON company . sales_data FROM data_analyst CASCADE ;
-- ===========================================================================
-- Revoking Role Assignments
-- Revoke role from user
REVOKE sales_team FROM ’ jane_smith ’@ ’% ’;
-- Revoke permissions from role
REVOKE DELETE ON company . orders FROM sales_team ;
-- Revoke role hierarchy
REVOKE data_analyst FROM hr_manager ;
-- ===========================================================================

Viewing Permissions
-- Show grants for specific user ( MySQL )
SHOW GRANTS FOR ’ john_doe ’@ ’ localhost ’;
-- Show grants for current user
SHOW GRANTS FOR CURRENT_USER () ;
-- Show all users and their privileges ( varies by database )
SELECT user , host , select_priv , insert_priv , update_priv
FROM mysql . user ;
-- ===========================================================================

System-Level Permissions
-- Grant system - level privileges
GRANT CREATE USER ON *.* TO ’ admin_user ’@ ’ localhost ’;
GRANT RELOAD ON *.* TO ’ backup_user ’@ ’ localhost ’;
-- Grant procedure execution rights
GRANT EXECUTE ON PROCEDURE company . calculate_bonus
TO hr_manager ;
-- Grant view creation rights
GRANT CREATE VIEW ON company .* TO data_analyst ;
-- ===========================================================================

-- Best Practices Example
-- 1. Create roles for different job functions
CREATE ROLE app_read_only ;
CREATE ROLE app_read_write ;
CREATE ROLE app_admin ;
-- 2. Grant minimal required permissions to roles
GRANT SELECT ON company .* TO app_read_only ;
GRANT SELECT , INSERT , UPDATE ON company .* TO app_read_write ;
GRANT ALL PRIVILEGES ON company .* TO app_admin ;
-- 3. Create users with strong authentication
CREATE USER ’ app_user ’@ ’ 192.168.1.% ’
IDENTIFIED BY ’ StrongPassword123 ! ’;
-- 4. Assign appropriate role to user
GRANT app_read_write TO ’ app_user ’@ ’ 192.168.1.% ’;
-- 5. Activate role ( MySQL 8.0+)
SET DEFAULT ROLE app_read_write TO ’ app_user ’@ ’ 192.168.1.% ’;
-- 6. Regular permission audit
SHOW GRANTS FOR ’ app_user ’@ ’ 192.168.1.% ’;

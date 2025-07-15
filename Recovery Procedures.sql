# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# RECOVERY PROCEDURES FOR DIFFERENT SCENARIOS
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =

# Complete database recovery from full backup
echo " === COMPLETE DATABASE RECOVERY === "
# 1. Stop MySQL service ( if running )
sudo systemctl stop mysql
# 2. Drop existing database ( if corrupted )
mysql -u root -p -e " DROP DATABASE IF EXISTS EmployeesDB ; "
# 3. Create fresh database
mysql -u root -p -e " CREATE DATABASE EmployeesDB ; "
# 4. Restore from backup
zcat / var / backups / mysql / full /
e m p lo y e e sdb_full_20241201_020000 . sql . gz | \
mysql -u root -p EmployeesDB
# 5. Verify restoration
mysql -u root -p EmployeesDB -e " SELECT COUNT (*) FROM
employees ; "
# Point - in - time recovery using binary logs
echo " === POINT - IN - TIME RECOVERY === "
# 1. Restore from last full backup ( as above )
# 2. Apply binary logs up to specific point
mysqlbinlog -- start - datetime = " 2024 -12 -01 02:00:00 " \
-- stop - datetime = " 2024 -12 -01 14:30:00 " \
/ var / backups / mysql / binlogs / mysql - bin .000123 |
\
mysql -u root -p EmployeesDB
# Table - specific recovery
echo " === TABLE - SPECIFIC RECOVERY === "
# Restore specific table from backup
mysql -u root -p EmployeesDB -e " DROP TABLE IF EXISTS
employees ; "
zcat / var / backups / mysql / critical / employees_20241201_140000
. sql . gz | \
mysql -u root -p EmployeesDB
# Schema - only recovery ( structure without data )
echo " === SCHEMA - ONLY RECOVERY === "
zcat / var / backups / mysql / full /
e m p l o y e e s db_schema_20241201_020000 . sql . gz | \
mysql -u root -p
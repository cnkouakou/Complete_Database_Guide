# !/ bin / bash
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# ENTERPRISE EMPLOYEESDB BACKUP SYSTEM
# Comprehensive backup strategy with multiple backup types
,
# retention policies , validation , and automated recovery
testing
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# CONFIGURATION VARIABLES
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Database connection parameters
DB_HOST = " localhost "
DB_USER = " backup_admin "
DB_PASSWORD = " BackupAdmin2024 ! "
DB_NAME = " EmployeesDB "
# Backup storage locations
BACKUP_BASE_DIR = " / var / backups / mysql "
FULL_BACKUP_DIR = " $ { BACKUP_BASE_DIR }/ full "
INCREMENTAL_BACKUP_DIR = " $ { BACKUP_BASE_DIR }/ incremental "
ARCHIVE_DIR = " $ { BACKUP_BASE_DIR }/ archive "
REMOTE_BACKUP_DIR = " s3 :// company - db - backups / employeesdb "
# Backup retention settings
DAILY_RETENTION_DAYS =7
WEEKLY_RETENTION_WEEKS =4
MONTHLY_RETENTION_MONTHS =12
YEARLY_RETENTION_YEARS =7
# Notification settings
EMAIL_RECIPIENTS = " dba@company . com , backup - alerts@company .
com "
SLACK_WEBHOOK = " https :// hooks . slack . com / services / YOUR / SLACK
/ WEBHOOK "
# Logging configuration
LOG_FILE = " / var / log / mysql_backup . log "
ERROR_LOG = " / var / log / mysql_backup_errors . log "
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# UTILITY FUNCTIONS
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Logging function with timestamp
log_message () {
local level = " $1 "
local message = " $2 "
echo " [ $ ( date ’+%Y -% m -% d % H :% M :% S ’) ] [ $level ] $message
" | tee -a " $LOG_FILE "
}
# Error handling and notification
handle_error () {
local error_message = " $1 "
log_message " ERROR " " $error_message "
echo " $error_message " >> " $ERROR_LOG "
# Send email notification
echo " Backup Error : $error_message " | mail -s " MySQL
Backup Failure " " $EMAIL_RECIPIENTS "
# Send Slack notification
curl -X POST -H ’ Content - type : application / json ’ \
-- data " {\ " text \ " :\ " MySQL Backup Error :
$error_message \ " } " \
" $SLACK_WEBHOOK "
exit 1
}
# Success notification
notify_success () {
local message = " $1 "
log_message " SUCCESS " " $message "
# Send success notification ( optional , can be
configured )
curl -X POST -H ’ Content - type : application / json ’ \
-- data " {\ " text \ " :\ " MySQL Backup Success : $message
\ " } " \
" $SLACK_WEBHOOK "
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# BACKUP FUNCTIONS
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Full database backup with comprehensive options
perform_full_backup () {
local backup_date = $ ( date ’ +% Y % m % d_ % H % M % S ’)
local backup_file = " $ { FULL_BACKUP_DIR }/
employeesdb_full_$ { backup_date }. sql "
local compressed_file = " $ { backup_file }. gz "
log_message " INFO " " Starting full backup of $DB_NAME
database "
# Create backup directory if it doesn ’ t exist
mkdir -p " $FULL_BACKUP_DIR "
# Perform mysqldump with comprehensive options
mysqldump \
-- host = " $DB_HOST " \
-- user = " $DB_USER " \
-- password = " $DB_PASSWORD " \
-- single - transaction \
-- routines \
-- triggers \
-- events \
-- add - drop - database \
-- create - options \
-- disable - keys \
-- extended - insert \
-- quick \
-- lock - tables = false \
-- add - locks \
-- hex - blob \
-- complete - insert \
-- comments \
-- dump - date \
-- master - data =2 \
-- flush - logs \
-- databases " $DB_NAME " > " $backup_file "
# Check if backup was successful
if [ $ ? - eq 0 ] && [ -s " $backup_file " ]; then
# Compress the backup file
gzip " $backup_file "
# Calculate and store checksum for integrity
verification
local checksum = $ ( sha256sum " $compressed_file " |
cut -d ’ ’ - f1 )
echo " $checksum $compressed_file " > " $ {
compressed_file }. sha256 "
# Get backup file size for reporting
local file_size = $ ( du -h " $compressed_file " | cut -
f1 )
log_message " SUCCESS " " Full backup completed :
$compressed_file ( Size : $file_size , Checksum :
$checksum ) "
# Upload to remote storage
upload_to_remote_storage " $compressed_file " " full "
return 0
else
handle_error " Full backup failed - mysqldump
returned error or backup file is empty "
fi
}
# Structure - only backup for schema versioning
perform_schema_backup () {
local backup_date = $ ( date ’ +% Y % m % d_ % H % M % S ’)
local schema_file = " $ { FULL_BACKUP_DIR }/
employeesdb_schema_$ { backup_date }. sql "
log_message " INFO " " Creating schema backup "
# Backup database structure only ( no data )
mysqldump \
-- host = " $DB_HOST " \
-- user = " $DB_USER " \
-- password = " $DB_PASSWORD " \
--no - data \
-- routines \
-- triggers \
-- events \
-- add - drop - database \
-- create - options \
-- comments \
-- databases " $DB_NAME " > " $schema_file "
if [ $ ? - eq 0 ]; then
gzip " $schema_file "
log_message " SUCCESS " " Schema backup completed : $ {
schema_file }. gz "
else
handle_error " Schema backup failed "
fi
}
# Table - specific backup for critical data
per fo r m_ c ri tical_tables_backup () {
local backup_date = $ ( date ’ +% Y % m % d_ % H % M % S ’)
local critical_backup_dir = " $ { BACKUP_BASE_DIR }/ critical
"
mkdir -p " $critical_backup_dir "
# Define critical tables that need frequent backup
local critical_tables =(
" employees "
" salary_history "
" performance_reviews "
" employee_audit_log "
" orders "
" customers "
)
log_message " INFO " " Starting critical tables backup "
for table in " $ { critical_tables [ @ ]} " ; do
local table_backup_file = " $ { critical_backup_dir }/ $ {
table } _$ { backup_date }. sql "
mysqldump \
-- host = " $DB_HOST " \
-- user = " $DB_USER " \
-- password = " $DB_PASSWORD " \
-- single - transaction \
-- add - drop - table \
-- complete - insert \
-- extended - insert \
-- quick \
-- lock - tables = false \
" $DB_NAME " " $table " > " $table_backup_file "
if [ $ ? - eq 0 ]; then
gzip " $table_backup_file "
log_message " SUCCESS " " Critical table backup
completed : $table "
else
log_message " ERROR " " Failed to backup critical
table : $table "
fi
done
}
# Binary log backup for point - in - time recovery
backup_binary_logs () {
local log_backup_dir = " $ { BACKUP_BASE_DIR }/ binlogs "
mkdir -p " $log_backup_dir "
log_message " INFO " " Backing up MySQL binary logs "
# Flush logs to close current binary log
mysql -- host = " $DB_HOST " -- user = " $DB_USER " -- password = "
$DB_PASSWORD " \
-e " FLUSH LOGS ; "
# Find MySQL data directory
local mysql_data_dir = $ ( mysql -- host = " $DB_HOST " -- user =
" $DB_USER " \
-- password = " $DB_PASSWORD " -e " SELECT @@datadir ; " -
s -N )
# Copy binary logs to backup location
find " $mysql_data_dir " - name " mysql - bin .* " - type f -
exec cp {} " $log_backup_dir / " \;
# Compress old binary logs
find " $log_backup_dir " - name " mysql - bin .* " - type f -
exec gzip {} \;
log_message " SUCCESS " " Binary log backup completed "
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# REMOTE STORAGE AND SYNCHRONIZATION
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Upload backups to remote storage ( AWS S3 , Google Cloud ,
etc .)
upload_to_remote_storage () {
local local_file = " $1 "
local backup_type = " $2 "
local remote_path = " $ { REMOTE_BACKUP_DIR }/ $ { backup_type
}/ $ ( basename " $local_file " ) "
log_message " INFO " " Uploading backup to remote storage
: $remote_path "
# Upload to S3 ( requires AWS CLI configuration )
aws s3 cp " $local_file " " $remote_path " -- storage - class
STANDARD_IA
if [ $ ? - eq 0 ]; then
log_message " SUCCESS " " Remote upload completed :
$remote_path "
# Upload checksum file as well
aws s3 cp " $ { local_file }. sha256 " " $ { remote_path }.
sha256 "
else
log_message " ERROR " " Remote upload failed :
$local_file "
fi
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# BACKUP VALIDATION AND TESTING
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Validate backup integrity and test restore capability
validate_backup () {
local backup_file = " $1 "
local test_db_name = " test_restore_$ ( date ’+% Y % m % d_ % H % M %
S ’) "
log_message " INFO " " Validating backup : $backup_file "
# Verify checksum if available
if [ -f " $ { backup_file }. sha256 " ]; then
if sha256sum -c " $ { backup_file }. sha256 " ; then
log_message " SUCCESS " " Backup checksum
verification passed "
else
handle_error " Backup checksum verification
failed : $backup_file "
fi
fi
# Test restore to temporary database
log_message " INFO " " Testing restore capability with
temporary database : $test_db_name "
# Create temporary test database
mysql -- host = " $DB_HOST " -- user = " $DB_USER " -- password = "
$DB_PASSWORD " \
-e " CREATE DATABASE $test_db_name ; "
# Restore backup to test database
if [[ " $backup_file " == *. gz ]]; then
zcat " $backup_file " | mysql -- host = " $DB_HOST " --
user = " $DB_USER " \
-- password = " $DB_PASSWORD " " $test_db_name "
else
mysql -- host = " $DB_HOST " -- user = " $DB_USER " --
password = " $DB_PASSWORD " \
" $test_db_name " < " $backup_file "
fi
if [ $ ? - eq 0 ]; then
# Verify data integrity with sample queries
local employee_count = $ ( mysql -- host = " $DB_HOST " --
user = " $DB_USER " \
-- password = " $DB_PASSWORD " " $test_db_name " \
-e " SELECT COUNT (*) FROM employees ; " -s -N )
if [ " $employee_count " - gt 0 ]; then
log_message " SUCCESS " " Backup validation
successful - restored $employee_count
employees "
else
log_message " WARNING " " Backup restored but no
data found in employees table "
fi
# Clean up test database
mysql -- host = " $DB_HOST " -- user = " $DB_USER " --
password = " $DB_PASSWORD " \
-e " DROP DATABASE $test_db_name ; "
else
handle_error " Backup validation failed - could not
restore backup : $backup_file "
fi
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# BACKUP RETENTION AND CLEANUP
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Clean up old backups based on retention policy
cleanup_old_backups () {
log_message " INFO " " Starting backup cleanup based on
retention policies "
# Clean up daily backups older than retention period
find " $FULL_BACKUP_DIR " - name " employeesdb_full_ *. sql .
gz " - type f \
- mtime + $DAILY_RETENTION_DAYS - delete
# Move old backups to archive
find " $FULL_BACKUP_DIR " - name " employeesdb_full_ *. sql .
gz " - type f \
- mtime + $ (( WEEKLY_RETENTION_WEEKS * 7) ) - exec mv
{} " $ARCHIVE_DIR / " \;
# Clean up critical table backups
find " $ { BACKUP_BASE_DIR }/ critical " - name " *. sql . gz " -
type f \
- mtime + $DAILY_RETENTION_DAYS - delete
# Clean up binary log backups
find " $ { BACKUP_BASE_DIR }/ binlogs " - name " mysql - bin .*.
gz " - type f \
- mtime + $ (( WEEKLY_RETENTION_WEEKS * 7) ) - delete
log_message " SUCCESS " " Backup cleanup completed "
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# MONITORING AND REPORTING
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Generate backup status report
generate_backup_report () {
local report_file = " $ { BACKUP_BASE_DIR }/ backup_report_$ (
date ’+% Y % m %d ’) . txt "
cat > " $report_file " << EOF
MySQL Backup Status Report
Generated : $ ( date )
Database : $DB_NAME
=== RECENT BACKUPS ===
$ ( find " $FULL_BACKUP_DIR " - name " *. sql . gz " - type f - mtime
-7 - exec ls - lh {} \;)
=== STORAGE USAGE ===
Total Backup Storage : $ ( du - sh " $BACKUP_BASE_DIR " | cut -
f1 )
Full Backups : $ ( du - sh " $FULL_BACKUP_DIR " | cut - f1 )
Critical Tables : $ ( du - sh " $ { BACKUP_BASE_DIR }/ critical "
2 >/ dev / null | cut - f1 || echo " 0 " )
Binary Logs : $ ( du - sh " $ { BACKUP_BASE_DIR }/ binlogs " 2 >/ dev /
null | cut - f1 || echo " 0 " )
=== VALIDATION STATUS ===
Last Validation : $ ( tail -n 20 " $LOG_FILE " | grep " Backup
validation successful " | tail -1 || echo " No recent
validations found " )
=== ERRORS ( Last 7 days ) ===
$ ( find " $ERROR_LOG " - mtime -7 - exec cat {} \; 2 >/ dev / null
|| echo " No errors found " )
EOF
# Email the report
mail -s " MySQL Backup Report - $ ( date ’+%Y -% m -% d ’) " "
$EMAIL_RECIPIENTS " < " $report_file "
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# MAIN BACKUP ORCHESTRATION
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Main backup function that orchestrates different backup
types
main_backup_routine () {
local backup_type = " $1 "
log_message " INFO " " Starting backup routine :
$backup_type "
case " $backup_type " in
" full " )
perform_full_backup
perform_schema_backup
backup_binary_logs
# Validate most recent backup
local latest_backup = $ ( ls -t " $FULL_BACKUP_DIR "
/ employeesdb_full_ *. sql . gz | head -1)
if [ -n " $latest_backup " ]; then
validate_backup " $latest_backup "
fi
cleanup_old_backups
notify_success " Full backup routine completed
successfully "
;;
" critical " )
perform_critical_tables_backup
backup_binary_logs
notify_success " Critical tables backup
completed successfully "
;;
" schema " )
perform_schema_backup
notify_success " Schema backup completed
successfully "
;;
" validate " )
local latest_backup = $ ( ls -t " $FULL_BACKUP_DIR "
/ employeesdb_full_ *. sql . gz | head -1)
if [ -n " $latest_backup " ]; then
validate_backup " $latest_backup "
else
handle_error " No backup files found for
validation "
fi
;;
" report " )
generate_backup_report
;;
*)
echo " Usage : $0 { full | critical | schema | validate
| report } "
echo " full - Complete database backup
with validation "
echo " critical - Backup critical tables only
"
echo " schema - Backup database structure
only "
echo " validate - Test restore capability of
latest backup "
echo " report - Generate backup status
report "
exit 1
;;
esac
}
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# BACKUP SCHEDULING EXAMPLES
# = = = = = = = = = == = = == = = == = == = = == = = == = == = = == = == = = == =
# Example crontab entries for automated backup scheduling :
#
# # Daily full backup at 2:00 AM
# 0 2 * * * / path / to / backup_script . sh full
#
# # Critical tables backup every 6 hours
# 0 */6 * * * / path / to / backup_script . sh critical
#
# # Schema backup weekly on Sunday at 1:00 AM
# 0 1 * * 0 / path / to / backup_script . sh schema
#
# # Backup validation weekly on Monday at 3:00 AM
# 0 3 * * 1 / path / to / backup_script . sh validate
#
# # Generate weekly backup report on Friday at 8:00 AM
# 0 8 * * 5 / path / to / backup_script . sh report
# Execute main function with provided argument
main_backup_routine " $1 "
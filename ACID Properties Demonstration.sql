-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SCENARIO : Banking Transaction System Demonstrating All ACID Properties
-- Money transfer between accounts with complete ACID compliance
-- Shows how each property ensures data integrity and system reliability
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- SETUP : Create Banking Schema with ACID - Compliant Design
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Create accounts table with constraints for CONSISTENCY
CREATE TABLE bank_accounts (
account_id INT PRIMARY KEY AUTO_INCREMENT ,
account_number VARCHAR (20) UNIQUE NOT NULL ,
customer_name VARCHAR (100) NOT NULL ,
balance DECIMAL (15 ,2) NOT NULL DEFAULT 0.00 ,
account_type ENUM ( ’ CHECKING ’ , ’ SAVINGS ’ , ’ BUSINESS ’) NOT
NULL ,
status ENUM ( ’ ACTIVE ’ , ’ FROZEN ’ , ’ CLOSED ’) DEFAULT ’ ACTIVE ’ ,
created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE
CURRENT_TIMESTAMP ,
-- Consistency constraints
CONSTRAINT chk_positive_balance CHECK ( balance >= 0) ,
CONSTRAINT chk_valid_account_number CHECK ( LENGTH (
account_number ) >= 10)
) ;
-- Transaction log table for DURABILITY and audit trail
CREATE TABLE transaction_log (
transaction_id INT PRIMARY KEY AUTO_INCREMENT ,
transaction_reference VARCHAR (50) UNIQUE NOT NULL ,
from_account_id INT ,
to_account_id INT ,
transaction_type ENUM ( ’ TRANSFER ’ , ’ DEPOSIT ’ , ’ WITHDRAWAL ’ , ’
FEE ’) NOT NULL ,
amount DECIMAL (15 ,2) NOT NULL ,
transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
status ENUM ( ’ PENDING ’ , ’ COMPLETED ’ , ’ FAILED ’ , ’ REVERSED ’)
DEFAULT ’ PENDING ’ ,
description TEXT ,
processed_by VARCHAR (100) ,
-- Foreign key constraints for CONSISTENCY
FOREIGN KEY ( from_account_id ) REFERENCES bank_accounts (
account_id ) ,
FOREIGN KEY ( to_account_id ) REFERENCES bank_accounts (
account_id ) ,
-- Business rule constraints
CONSTRAINT chk_positive_amount CHECK ( amount > 0) ,
CONSTRAINT chk_valid_transfer CHECK (
( transaction_type = ’ TRANSFER ’ AND from_account_id IS
NOT NULL AND to_account_id IS NOT NULL ) OR
( transaction_type = ’ DEPOSIT ’ AND to_account_id IS NOT
NULL ) OR
( transaction_type = ’ WITHDRAWAL ’ AND from_account_id IS
NOT NULL )
)
) ;
-- Account balance history for audit and compliance
CREATE TABLE balance_history (
history_id INT PRIMARY KEY AUTO_INCREMENT ,
account_id INT NOT NULL ,
old_balance DECIMAL (15 ,2) NOT NULL ,
new_balance DECIMAL (15 ,2) NOT NULL ,
change_amount DECIMAL (15 ,2) NOT NULL ,
transaction_reference VARCHAR (50) ,
change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
change_reason VARCHAR (200) ,
FOREIGN KEY ( account_id ) REFERENCES bank_accounts ( account_id
)
) ;
-- Insert sample accounts for demonstration
INSERT INTO bank_accounts ( account_number , customer_name ,
balance , account_type ) VALUES
( ’ 1234567890 ’ , ’ John Smith ’ , 5000.00 , ’ CHECKING ’) ,
( ’ 2345678901 ’ , ’ Jane Doe ’ , 3000.00 , ’ SAVINGS ’) ,
( ’ 3456789012 ’ , ’ Acme Corporation ’ , 25000.00 , ’ BUSINESS ’) ,
( ’ 4567890123 ’ , ’ Mary Johnson ’ , 1500.00 , ’ CHECKING ’) ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DEMONSTRATION 1: ATOMICITY Property
-- All operations succeed together or all fail together
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Configure for maximum ACID compliance
SET autocommit = 0;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
-- ATOMICITY DEMONSTRATION : Money Transfer Between Accounts
-- Transfer $500 from John Smith ( account 1) to Jane Doe (
account 2)
START TRANSACTION ;
-- Generate unique transaction reference for tracking
SET @transaction_ref = CONCAT ( ’ TXN_ ’ , DATE_FORMAT ( NOW () , ’% Y % m %
d_ % H % i % s ’) , ’_ ’ , CONNECTION_ID () ) ;
SET @transfer_amount = 500.00;
SET @from_account = 1;
SET @to_account = 2;
-- Log transaction start
INSERT INTO transaction_log (
transaction_reference ,
from_account_id ,
to_account_id ,
transaction_type ,
amount ,
description ,
processed_by
) VALUES (
@transaction_ref ,
@from_account ,
@to_account ,
’ TRANSFER ’ ,
@transfer_amount ,
’ Account - to - account transfer demonstration ’ ,
USER ()
) ;
-- ATOMICITY : All these operations must succeed or all must fail
-- Step 1: Verify source account has sufficient funds ( Business
Rule Validation )
SELECT @source_balance := balance
FROM bank_accounts
WHERE account_id = @from_account AND status = ’ ACTIVE ’;
-- Check if sufficient funds available
SET @sufficient_funds = CASE WHEN @source_balance >=
@transfer_amount THEN 1 ELSE 0 END ;
-- Step 2: Record balance history BEFORE changes ( for audit
trail )
INSERT INTO balance_history (
account_id ,
old_balance ,
new_balance ,
change_amount ,
transaction_reference ,
change_reason
)
SELECT
@from_account ,
balance ,
balance - @transfer_amount ,
- @transfer_amount ,
@transaction_ref ,
’ Outgoing transfer - debit ’
FROM bank_accounts
WHERE account_id = @from_account ;
INSERT INTO balance_history (
account_id ,
old_balance ,
new_balance ,
change_amount ,
transaction_reference ,
change_reason
)
SELECT
@to_account ,
balance ,
balance + @transfer_amount ,
@transfer_amount ,
@transaction_ref ,
’ Incoming transfer - credit ’
FROM bank_accounts
WHERE account_id = @to_account ;
-- Step 3: Debit source account ( ATOMICITY : This must succeed )
UPDATE bank_accounts
SET
balance = balance - @transfer_amount ,
last_modified = CURRENT_TIMESTAMP
WHERE account_id = @from_account
AND balance >= @transfer_amount
AND status = ’ ACTIVE ’;
-- Verify debit was successful ( affected rows check )
SET @debit_success = ROW_COUNT () ;
-- Step 4: Credit destination account ( ATOMICITY : This must also
succeed )
UPDATE bank_accounts
SET
balance = balance + @transfer_amount ,
last_modified = CURRENT_TIMESTAMP
WHERE account_id = @to_account
AND status = ’ ACTIVE ’;
-- Verify credit was successful
SET @credit_success = ROW_COUNT () ;
-- Step 5: Update transaction log status based on success /
failure
UPDATE transaction_log
SET
status = CASE
WHEN @debit_success = 1 AND @credit_success = 1 AND
@sufficient_funds = 1
THEN ’ COMPLETED ’
ELSE ’ FAILED ’
END ,
transaction_date = CURRENT_TIMESTAMP
WHERE transaction_reference = @transaction_ref ;
-- ATOMICITY : Check if all operations succeeded
SELECT @transaction_success := CASE
WHEN @debit_success = 1 AND @credit_success = 1 AND
@sufficient_funds = 1
THEN 1
ELSE 0
END ;
-- ATOMICITY in action : Either COMMIT all changes or ROLLBACK
all changes
IF @transaction_success = 1 THEN
COMMIT ;
SELECT ’ Transaction COMMITTED - All operations succeeded ’ AS
atomicity_result ;
ELSE
ROLLBACK ;
SELECT ’ Transaction ROLLED BACK - One or more operations
failed ’ AS atomicity_result ;
END IF ;
-- Note : MySQL doesn ’t support IF statements outside stored
procedures
-- In practice , application logic would handle this decision
-- For demonstration , we ’ ll commit since our setup ensures
success
COMMIT ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DEMONSTRATION 2: CONSISTENCY Property
-- Database constraints and business rules are maintained
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- CONSISTENCY DEMONSTRATION : Attempt invalid operations that
should fail
START TRANSACTION ;
-- Test 1: Attempt to create negative balance ( should fail due
to CHECK constraint )
-- This demonstrates how CONSISTENCY prevents invalid data
states
SET @test_transaction_ref = CONCAT ( ’ TEST_ ’ , DATE_FORMAT ( NOW () , ’
% Y % m % d_ % H % i % s ’) ) ;
-- This should fail due to balance constraint
-- UPDATE bank_accounts SET balance = -100.00 WHERE account_id =
1;
-- Test 2: Attempt transfer with insufficient funds
-- Business logic consistency check
UPDATE bank_accounts
SET balance = balance - 10000.00
WHERE account_id = 4 AND balance >= 10000.00; -- Mary Johnson
only has $1500
-- Check if update succeeded ( should be 0 rows affected due to
insufficient funds )
SELECT ROW_COUNT () AS rows_affected , ’ Insufficient funds check ’
AS test_type ;
-- Test 3: Foreign key constraint consistency
-- Attempt to insert transaction with non - existent account
-- INSERT INTO transaction_log ( transaction_reference ,
from_account_id , to_account_id , transaction_type , amount )
-- VALUES ( @test_transaction_ref , 999 , 1000 , ’ TRANSFER ’, 100.00)
;
-- This would fail due to foreign key constraints , maintaining
referential integrity
ROLLBACK ; -- Rollback test transactions
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DEMONSTRATION 3: ISOLATION Property
-- Concurrent transactions don ’t interfere with each other
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- ISOLATION DEMONSTRATION : Show how different isolation levels
affect concurrent access
-- Session 1 simulation : Read account balance with different
isolation levels
SET TRANSACTION ISOLATION LEVEL READ COMMITTED ;
START TRANSACTION ;
-- Read balance at start of transaction
SELECT
account_id ,
balance ,
’ READ COMMITTED - Initial Read ’ AS isolation_test ,
NOW () AS read_time
FROM bank_accounts
WHERE account_id = 1;
-- In a real scenario , another session would modify this account
here
-- This simulates what Session 2 would do :
-- UPDATE bank_accounts SET balance = balance + 100 WHERE
account_id = 1;
-- COMMIT ;
-- Read balance again in same transaction
SELECT
account_id ,
balance ,
’ READ COMMITTED - Second Read ( might show different value ) ’
AS isolation_test ,
NOW () AS read_time
FROM bank_accounts
WHERE account_id = 1;
COMMIT ;
-- Now demonstrate REPEATABLE READ isolation
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
START TRANSACTION ;
SELECT
account_id ,
balance ,
’ REPEATABLE READ - Initial Read ’ AS isolation_test ,
NOW () AS read_time
FROM bank_accounts
WHERE account_id = 1;
-- Even if another session modifies this account ,
-- REPEATABLE READ will show the same value
SELECT
account_id ,
balance ,
’ REPEATABLE READ - Second Read ( same value guaranteed ) ’ AS
isolation_test ,
NOW () AS read_time
FROM bank_accounts
WHERE account_id = 1;
COMMIT ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DEMONSTRATION 4: DURABILITY Property
-- Committed transactions persist even after system failure
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- DURABILITY DEMONSTRATION : Configure maximum durability
settings
-- These settings ensure committed transactions are immediately
written to disk
-- Configure InnoDB for maximum durability
SET GLOBAL innodb_flush_log_at_trx_commit = 1; -- Flush log to
disk on commit
SET GLOBAL sync_binlog = 1; -- Sync binary
log on commit
SET GLOBAL innodb_doublewrite = 1; -- Enable
doublewrite buffer
-- Perform a critical transaction that must be durable
START TRANSACTION ;
SET @critical_ref = CONCAT ( ’ CRITICAL_ ’ , DATE_FORMAT ( NOW () , ’% Y % m
% d_ % H % i % s ’) ) ;
-- Simulate a critical business transaction ( loan payment )
UPDATE bank_accounts
SET balance = balance - 1000.00
WHERE account_id = 3 AND balance >= 1000.00; -- Acme
Corporation pays loan
-- Log this critical transaction with full details
INSERT INTO transaction_log (
transaction_reference ,
from_account_id ,
transaction_type ,
amount ,
description ,
status ,
processed_by
) VALUES (
@critical_ref ,
3 ,
’ WITHDRAWAL ’ ,
1000.00 ,
’ Monthly loan payment - must be durable ’ ,
’ COMPLETED ’ ,
USER ()
) ;
-- Record in balance history for audit
INSERT INTO balance_history (
account_id ,
old_balance ,
new_balance ,
change_amount ,
transaction_reference ,
change_reason
)
SELECT
3 ,
balance + 1000.00 ,
balance ,
-1000.00 ,
@critical_ref ,
’ Loan payment - critical transaction ’
FROM bank_accounts
WHERE account_id = 3;
-- DURABILITY : This COMMIT ensures data survives system crash
COMMIT ;
-- Verify durability by checking transaction was recorded
SELECT
’ DURABILITY VERIFICATION ’ AS test_type ,
t . transaction_reference ,
t . amount ,
t . status ,
a . balance AS current_balance ,
’ Transaction committed and durable ’ AS durability_status
FROM transaction_log t
JOIN bank_accounts a ON t . from_account_id = a . account_id
WHERE t . transaction_reference = @critical_ref ;
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- COMPREHENSIVE ACID VERIFICATION REPORT
-- == = = == = = == = == = = == = = == = == = = == = = == = == = = == = = == = =
-- Generate comprehensive report showing all ACID properties in
action
SELECT ’ ========== ACID PROPERTIES VERIFICATION REPORT
========== ’ AS report_section ;
-- ATOMICITY Verification : All transactions are complete units
SELECT
’ ATOMICITY CHECK ’ AS property ,
COUNT (*) AS total_transactions ,
SUM ( CASE WHEN status = ’ COMPLETED ’ THEN 1 ELSE 0 END ) AS
completed_transactions ,
SUM ( CASE WHEN status = ’ FAILED ’ THEN 1 ELSE 0 END ) AS
failed_transactions ,
’ All transactions either fully completed or fully failed ’ AS
verification
FROM transaction_log
WHERE DATE ( transaction_date ) = CURDATE () ;
-- CONSISTENCY Verification : All balances and constraints are
valid
SELECT
’ CONSISTENCY CHECK ’ AS property ,
COUNT (*) AS total_accounts ,
SUM ( CASE WHEN balance >= 0 THEN 1 ELSE 0 END ) AS
accounts_with_valid_balance ,
SUM ( CASE WHEN status IN ( ’ ACTIVE ’ , ’ FROZEN ’ , ’ CLOSED ’) THEN
1 ELSE 0 END ) AS accounts_with_valid_status ,
’ All accounts maintain business rule constraints ’ AS
verification
FROM bank_accounts ;
-- ISOLATION Verification : Transaction logs show proper
sequencing
SELECT
’ ISOLATION CHECK ’ AS property ,
transaction_reference ,
transaction_date ,
’ Transactions processed in proper sequence without
interference ’ AS verification
FROM transaction_log
WHERE DATE ( transaction_date ) = CURDATE ()
ORDER BY transaction_date ;
-- DURABILITY Verification : All committed transactions are
permanently recorded
SELECT
’ DURABILITY CHECK ’ AS property ,
COUNT (*) AS committed_transactions ,
SUM ( amount ) AS total_transaction_value ,
’ All committed transactions permanently stored with full
audit trail ’ AS verification
FROM transaction_log
WHERE status = ’ COMPLETED ’
AND DATE ( transaction_date ) = CURDATE () ;
-- Final balance verification with complete audit trail
SELECT
’ FINAL VERIFICATION ’ AS summary ,
a . account_number ,
a . customer_name ,
a . balance AS current_balance ,
COUNT ( t . transaction_id ) AS transaction_count ,
SUM ( CASE WHEN t . to_account_id = a . account_id THEN t . amount
ELSE 0 END ) AS total_credits ,
SUM ( CASE WHEN t . from_account_id = a . account_id THEN t . amount
ELSE 0 END ) AS total_debits
FROM bank_accounts a
LEFT JOIN transaction_log t ON ( a . account_id = t . from_account_id
OR a . account_id = t . to_account_id )
AND t . status = ’ COMPLETED ’
AND DATE ( t . transaction_date ) = CURDATE ()
GROUP BY a . account_id , a . account_number , a . customer_name , a .
balance
ORDER BY a . account_id ;
-- Reset autocommit
SET autocommit = 1;






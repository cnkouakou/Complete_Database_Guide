-- Auto-commit vs Manual Transaction Control
-- Listing 7.17: Setting Transaction Isolation
-- Check current auto - commit status ( MySQL )
SELECT @@autocommit ;
-- Disable auto - commit for manual transaction control
SET autocommit = 0;
-- Now each statement needs explicit COMMIT
INSERT INTO test_table ( id , name ) VALUES (1 , ’ Test ’) ;
-- This change is not yet permanent
-- Make it permanent
COMMIT ;
-- Re - enable auto - commit
SET autocommit = 1;
-- PostgreSQL equivalent
-- BEGIN ; -- Starts transaction block
-- ... SQL statements ...
-- COMMIT ; -- or ROLLBACK ;
-- Set transaction isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED ;
BEGIN ;
-- Perform operations with specified isolation level
SELECT balance FROM accounts WHERE account_id = 1001;
UPDATE accounts
SET balance = balance - 100.00
WHERE account_id = 1001;
COMMIT ;
-- Other isolation levels :
-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
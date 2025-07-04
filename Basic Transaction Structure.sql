-- Basic Transaction Structure

-- Start a transaction
BEGIN ; -- or START TRANSACTION ;
-- Perform multiple operations
INSERT INTO accounts ( account_id , customer_name , balance )
VALUES (1001 , ’ John Doe ’ , 5000.00) ;
UPDATE accounts
SET balance = balance - 500.00
WHERE account_id = 1001;
INSERT INTO transactions ( account_id , transaction_type , amount )
VALUES (1001 , ’ WITHDRAWAL ’ , 500.00) ;
-- Commit the transaction ( make changes permanent )
COMMIT ;
-- ================================================================================
-- Transaction with ROLLBACK
-- Start transaction
BEGIN ;
-- Attempt to transfer money between accounts
UPDATE accounts
SET balance = balance - 1000.00
WHERE account_id = 1001;
-- Check if sufficient funds ( this would be done in application
logic )
-- If insufficient funds , rollback the transaction
UPDATE accounts
SET balance = balance + 1000.00
WHERE account_id = 1002;
-- If any error occurs , rollback all changes
ROLLBACK ;
-- Alternative : If all operations successful
-- COMMIT ;

-- ================================================================================
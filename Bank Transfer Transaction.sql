-- Bank Transfer Transaction
-- Listing 7.13: Complete Bank Transfer Transaction
-- Bank transfer : Move $500 from Account 1001 to Account 1002
BEGIN ;
-- Check source account balance ( in real application )
SELECT 
    balance
FROM
    accounts
WHERE
    account_id = 1001;
-- Debit source account
UPDATE accounts 
SET 
    balance = balance - 500.00,
    last_updated = CURRENT_TIMESTAMP
WHERE
    account_id = 1001 AND balance >= 500.00;
-- Verify the update affected exactly one row
-- ( This check would be done in application code )
-- Credit destination account
UPDATE accounts 
SET 
    balance = balance + 500.00,
    last_updated = CURRENT_TIMESTAMP
WHERE
    account_id = 1002;
-- Record the transaction
INSERT INTO transaction_log (
from_account ,
to_account ,
amount ,
transaction_date ,
description
) VALUES (
1001 ,
1002 ,
500.00 ,
CURRENT_TIMESTAMP ,
’ Account transfer ’
) ;
-- If all operations successful , commit
COMMIT ;
-- If any error occurred , all changes would be rolled back
-- ROLLBACK ;

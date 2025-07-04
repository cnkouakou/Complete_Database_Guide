--  Transaction Best Practices
-- Listing 7.19: Transaction Best Practices

-- 1. Keep transactions short to minimize locks
BEGIN ;
-- Perform only related operations
-- Avoid user interaction within transactions
COMMIT ;
-- 2. Use savepoints for complex operations
BEGIN ;
SAVEPOINT before_complex_operation ;
-- Risky operation
-- IF error THEN ROLLBACK TO before_complex_operation ;
COMMIT ;
-- 3. Always handle transaction cleanup
BEGIN ;
-- Operations ...
-- Always ensure either COMMIT or ROLLBACK is called
-- Never leave transactions hanging
COMMIT ; -- or ROLLBACK ;
-- 4. Use appropriate isolation levels
SET TRANSACTION ISOLATION LEVEL READ COMMITTED ;
-- Choose based on consistency vs . performance needs
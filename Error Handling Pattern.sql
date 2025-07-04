-- Error Handling Pattern
-- Listing 7.18: Transaction Error Handling Pattern
-- Typical error handling pattern ( pseudo - code with SQL )
BEGIN ;
-- Declare variables for error handling
-- SET @error_count = 0;
-- Operation 1
INSERT INTO table1 ( col1 , col2 ) VALUES ( ’ value1 ’ , ’ value2 ’) ;
-- IF ERROR THEN SET @error_count = @error_count + 1;
-- Operation 2
UPDATE table2 SET col1 = ’ new_value ’ WHERE id = 123;
-- IF ERROR THEN SET @error_count = @error_count + 1;
-- Operation 3
DELETE FROM table3 WHERE status = ’ inactive ’;
-- IF ERROR THEN SET @error_count = @error_count + 1;
-- Check for errors and commit or rollback
-- IF @error_count = 0 THEN
COMMIT ;
-- ELSE
-- ROLLBACK ;
-- END IF ;

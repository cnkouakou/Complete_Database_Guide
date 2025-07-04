-- SQL Server stored procedure syntax
CREATE PROCEDURE procedure_name
@parameter1 datatype ,
@parameter2 datatype OUTPUT
AS
BEGIN
-- Procedure body
SELECT statements ;
UPDATE statements ;
-- Control flow
IF condition
BEGIN
-- statements
END
ELSE
BEGIN
-- statements
END
END ;
-- Execute stored procedure
EXEC procedure_name @param1_value , @param2_value OUTPUT ;
-- MySQL stored procedure syntax
DELIMITER //
CREATE PROCEDURE procedure_name (
IN param1 datatype ,
OUT param2 datatype
)
BEGIN
-- Procedure body
SELECT statements ;
IF condition THEN
-- statements
ELSE
-- statements
END IF ;
END //
DELIMITER ;

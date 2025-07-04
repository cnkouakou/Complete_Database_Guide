-- Using SAVEPOINT

-- Start transaction
BEGIN ;
-- Insert first customer
INSERT INTO customers ( customer_id , name , email )
VALUES (1 , ’ Alice Johnson ’ , ’ alice@email . com ’) ;
-- Create savepoint after first insert
SAVEPOINT customer1_inserted ;
-- Insert second customer
INSERT INTO customers ( customer_id , name , email )
VALUES (2 , ’ Bob Smith ’ , ’ bob@email . com ’) ;
-- Create another savepoint
SAVEPOINT customer2_inserted ;
-- Attempt third customer insert ( might have duplicate email )
INSERT INTO customers ( customer_id , name , email )
VALUES (3 , ’ Charlie Brown ’ , ’ alice@email . com ’) ; -- Duplicateemail
-- If error occurs , rollback to previous savepoint
ROLLBACK TO customer2_inserted ;
-- Continue with other operations
INSERT INTO customer_preferences ( customer_id , newsletter )
VALUES (1 , true ) , (2 , false ) ;
-- Commit the entire transaction
COMMIT ;
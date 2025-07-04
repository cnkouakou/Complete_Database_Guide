-- Complex Business Transaction
-- Process customer order with inventory management
-- Listing 7.15: Order Processing Transaction
BEGIN ;
-- Create the order
INSERT INTO orders ( order_id , customer_id , order_date ,
total_amount )
VALUES (5001 , 123 , CURRENT_DATE , 299.98) ;
-- Create savepoint after order creation
SAVEPOINT order_created ;
-- Add order items and update inventory
INSERT INTO order_items ( order_id , product_id , quantity ,
unit_price )
VALUES (5001 , ’ PROD001 ’ , 2 , 99.99) ;
-- Update inventory
UPDATE inventory
SET quantity_available = quantity_available - 2 ,
last_updated = CURRENT_TIMESTAMP
WHERE product_id = ’ PROD001 ’
AND quantity_available >= 2;
-- Check if inventory update was successful
-- ( In real application , check affected row count )
-- Add second item
INSERT INTO order_items ( order_id , product_id , quantity ,
unit_price )
VALUES (5001 , ’ PROD002 ’ , 1 , 99.99) ;
-- Update inventory for second item
UPDATE inventory
SET quantity_available = quantity_available - 1 ,
last_updated = CURRENT_TIMESTAMP
WHERE product_id = ’ PROD002 ’
AND quantity_available >= 1;
-- Create payment record
INSERT INTO payments ( order_id , payment_method , amount ,
payment_date )
VALUES (5001 , ’ CREDIT_CARD ’ , 299.98 , CURRENT_TIMESTAMP ) ;
-- Update customer loyalty points
UPDATE customers
SET loyalty_points = loyalty_points + 30
WHERE customer_id = 123;

-- If all operations successful , commit
COMMIT ;
-- Example of partial rollback if payment fails
-- ROLLBACK TO order_created ;
-- UPDATE orders SET status = ’ PAYMENT_FAILED ’ WHERE order_id =
5001;
-- COMMIT ;
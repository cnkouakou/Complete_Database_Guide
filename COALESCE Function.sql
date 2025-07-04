-- Basic NULL handling with fallback values
SELECT
employee_id , first_name , last_name ,
COALESCE ( middle_name , ’ ’) AS middle_name_display ,
COALESCE ( phone_work , phone_home , phone_mobile , ’ No Phone ’)
AS contact_phone ,
COALESCE ( email_work , email_personal , ’ noemail@company . com ’)
AS contact_email
FROM employees
ORDER BY last_name ;
-- Data consolidation from multiple sources
SELECT
customer_id ,
COALESCE ( current_address . street , historical_address . street ,
’ Address Unknown ’) AS street ,
COALESCE ( current_address . city , historical_address . city , ’
City Unknown ’) AS city ,
COALESCE ( current_address . state , historical_address . state , ’
State Unknown ’) AS state ,
COALESCE ( current_profile . customer_name , legacy_profile .
customer_name , ’ Unknown Customer ’) AS customer_name
FROM customers c
LEFT JOIN current_addresses current_address ON c . customer_id =
current_address . customer_id
LEFT JOIN historical_addresses historical_address ON c .
customer_id = historical_address . customer_id
LEFT JOIN current_customer_profiles current_profile ON c .
customer_id = current_profile . customer_id
LEFT JOIN legacy_customer_profiles legacy_profile ON c .
customer_id = legacy_profile . customer_id ;
-- Mathematical calculations with NULL protection
SELECT
product_id , product_name ,
base_price ,
COALESCE ( discount_amount , 0) AS discount_amount ,
base_price - COALESCE ( discount_amount , 0) AS final_price ,
COALESCE ( tax_rate , 0.08) AS tax_rate , -- Default 8% tax
rate
( base_price - COALESCE ( discount_amount , 0) ) * (1 + COALESCE (
tax_rate , 0.08) ) AS total_price
FROM products
ORDER BY final_price DESC ;
-- String concatenation with NULL handling
SELECT
customer_id ,
COALESCE ( first_name , ’ ’) + ’ ’ + COALESCE ( middle_name + ’ ’ ,
’ ’) + COALESCE ( last_name , ’ ’) AS full_name ,
COALESCE ( address_line1 , ’ ’) +
CASE WHEN address_line2 IS NOT NULL THEN ’ , ’ +
address_line2 ELSE ’ ’ END +
’ , ’ + COALESCE ( city , ’ Unknown City ’) +
’ , ’ + COALESCE ( state , ’ Unknown State ’) AS full_address
FROM customers
WHERE COALESCE ( first_name , last_name ) IS NOT NULL ; -- At least
one name component exists
-- Complex fallback logic for reporting
SELECT
order_id , customer_id ,
order_date ,
COALESCE ( shipped_date , estimated_ship_date ,
DATEADD ( DAY , 3 , order_date ) , ’ 1900 -01 -01 ’) AS
display_ship_date ,
CASE
WHEN shipped_date IS NOT NULL THEN ’ Shipped ’
WHEN estimated_ship_date IS NOT NULL THEN ’ Estimated ’
ELSE ’ Pending ’
END AS ship_status ,
COALESCE ( tracking_number , ’TBD - ’ + CAST ( order_id AS VARCHAR )
) AS tracking_display
FROM orders
WHERE order_date >= DATEADD ( MONTH , -3 , GETDATE () )
ORDER BY COALESCE ( shipped_date , estimated_ship_date , order_date )
DESC ;
-- Using COALESCE in aggregate functions and window functions
SELECT
department ,
employee_id , salary , bonus ,
COALESCE ( salary , 0) + COALESCE ( bonus , 0) AS
total_compensation ,
AVG ( COALESCE ( salary , 0) ) OVER ( PARTITION BY department ) AS
dept_avg_salary ,
SUM ( COALESCE ( bonus , 0) ) OVER ( PARTITION BY department ) AS
dept_total_bonus ,
COALESCE ( performance_rating , ’ Not Rated ’) AS rating
FROM employees
ORDER BY department , total_compensation DESC 
-- Data type handling and conversion
SELECT
product_id ,
COALESCE ( CAST ( numeric_code AS VARCHAR ) , text_code , ’NO - CODE ’
) AS product_code ,
COALESCE ( weight_kg , weight_lbs * 0.453592 , 0.0) AS
weight_in_kg ,
COALESCE ( length_cm , length_inches * 2.54 , 0.0) AS
length_in_cm
FROM products
WHERE COALESCE ( numeric_code , CAST ( text_code AS INT ) , 0) > 0;

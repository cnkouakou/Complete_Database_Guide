-- Employee hierarchy : Find all subordinates under a manager
WITH RECURSIVE employee_hierarchy AS (
-- Anchor member : Start with the top manager
SELECT employee_id , first_name , last_name , manager_id ,
first_name + ’ ’ + last_name AS manager_name ,
0 AS level
FROM employees
WHERE manager_id IS NULL -- Top - level manager
UNION ALL
-- Recursive member : Find direct reports
SELECT e . employee_id , e . first_name , e . last_name , e .
manager_id ,
eh . first_name + ’ ’ + eh . last_name AS manager_name ,
eh . level + 1 AS level
FROM employees e
INNER JOIN employee_hierarchy eh ON e . manager_id = eh .
employee_id
WHERE eh . level < 10 -- Prevent infinite recursion
)
SELECT employee_id ,
REPLICATE ( ’ ’ , level ) + first_name + ’ ’ + last_name AS
hierarchy_display ,
level ,
manager_name
FROM employee_hierarchy
ORDER BY level , last_name ;
-- Bill of Materials : Find all components for a product
WITH RECURSIVE bom_explosion AS (
-- Anchor : Start with the main product
SELECT product_id , component_id , quantity , 1 AS level ,
CAST ( product_id AS VARCHAR (1000) ) AS path
FROM bill_of_materials
WHERE product_id = ’ MAIN_PRODUCT ’
UNION ALL
-- Recursive : Find sub - components
SELECT bom . product_id , bom . component_id ,
bom . quantity * be . quantity AS total_quantity ,
be . level + 1 AS level ,
be . path + ’ -> ’ + bom . component_id AS path
FROM bill_of_materials bom
INNER JOIN bom_explosion be ON bom . product_id = be .
component_id
WHERE be . level < 5 -- Limit recursion depth
AND CHARINDEX ( bom . component_id , be . path ) = 0 -- Prevent
circular references
)
SELECT component_id ,
SUM ( total_quantity ) AS total_required ,
level ,
path
FROM bom_explosion
GROUP BY component_id , level , path
ORDER BY level , component_id ;
-- Number series generation using recursion
WITH RECURSIVE number_series AS (
-- Anchor : Start with 1
SELECT 1 AS num
UNION ALL
-- Recursive : Generate next number
SELECT num + 1
FROM number_series
WHERE num < 100 -- Generate numbers 1 to 100
)
SELECT num ,
num * num AS squared ,
CASE WHEN num % 2 = 0 THEN 'Even' ELSE 'Odd' END AS
parity
FROM number_series
ORDER BY num ;


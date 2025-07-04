-- Create materialized view ( Oracle )
CREATE MATERIALIZED VIEW mv_name
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT columns
FROM tables
WHERE conditions ;
-- Create materialized view with automatic refresh ( Oracle )
CREATE MATERIALIZED VIEW mv_name
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT columns
FROM tables
WHERE conditions ;
-- PostgreSQL materialized view
CREATE MATERIALIZED VIEW mv_name AS
SELECT columns
FROM tables
WHERE conditions ;
-- Refresh materialized view
REFRESH MATERIALIZED VIEW mv_name ;
-- Drop materialized view
DROP MATERIALIZED VIEW mv_name ;
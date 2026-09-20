/*
==============================================================================
                      CREATE DATABASE AND SCHEMAS
==============================================================================
Script Purpose:
  This script create a new database inside your database, I'm using Postgresql. And it create  3 schemas for the project as
  'bronze', 'silver', 'gold'
WARNING:
  There is no particular warning using this script.


*/

-- STEP 1: CREATE NEW DATABASE ACCORDING TO THE DATABASE YOU ARE USING, IN MY CASE IT'S POSTGRESQL

--COMMNAD 1:
CREATE DATABASE DataWarehouse;

--THEN FROM pgAdmin Right Click On Database name and select  Query Tool.
-- STEP 2: CREATE SCHEMAS FOR EVERY LAYER (Bronze, Silver, Gold)
CREATE SCHEMA bronze; -- for Silver Layer and so on
CREATE SCHEMA silver;
CREATE SCHEMA gold;

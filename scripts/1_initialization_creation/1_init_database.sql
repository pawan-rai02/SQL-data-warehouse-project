/********************************************************************************************
 Purpose     : This script creates a new SQL Server database named 'DataWarehouse' 
               with three schemas: bronze, silver, and gold. These schemas represent 
               different layers of a typical data warehouse architecture:
                   - Bronze : Raw, unprocessed data
                   - Silver : Cleaned and transformed data
                   - Gold   : Aggregated, business-ready data for reporting/analytics

 Warnings    : ⚠️ 
   1. This script will DROP the 'DataWarehouse' database if it already exists. 
      All existing data will be permanently deleted.
   2. Ensure you have backups before running this script in production.
   3. Run this script with a user having sufficient privileges (DBA or sysadmin).

 Author      : [Pawan Kumar Rai]
 Date        : [05 September 2025, Friday]
********************************************************************************************/

-- Switch to the master database (required for creating/dropping databases)
USE master;
GO

-- Check if the database already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Force the database into SINGLE_USER mode to disconnect all active sessions
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Drop the existing database
    DROP DATABASE DataWarehouse;
END;
GO

-- Create a new DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the new database
USE DataWarehouse;
GO

-- Create schema layers for Data Warehouse architecture
-- Bronze: Raw, unprocessed data
CREATE SCHEMA bronze;
GO

-- Silver: Cleaned and transformed data
CREATE SCHEMA silver;
GO

-- Gold: Aggregated, business-ready data for reporting/analytics
CREATE SCHEMA gold;
GO

/********************************************************************************************
 Script Name : bronze.load_bronze
 Purpose     : Truncate all bronze CRM and ERP tables and bulk insert data from CSV files with duration logging.
********************************************************************************************/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @total_start DATETIME, @total_end DATETIME;

    SET @total_start = GETDATE();  -- Start timer for the whole Bronze layer

    BEGIN TRY
        PRINT '===================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===================================';

        PRINT '-----------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-----------------------------------';

        -- 1. CRM Customer Information
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT ' >> Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\SQLdataWarehouse\datasets\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        -- 2. CRM Product Information
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT ' >> Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\SQLdataWarehouse\datasets\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        -- 3. CRM Sales Details
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT ' >> Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\SQLdataWarehouse\datasets\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        PRINT '-----------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-----------------------------------';

        -- 1. ERP Customer
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT ' >> Inserting Data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\SQLdataWarehouse\datasets\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        -- 2. ERP Location
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT ' >> Inserting Data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\SQLdataWarehouse\datasets\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        -- 3. ERP Product Category
        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT ' >> Inserting Data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\SQLdataWarehouse\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

        SET @end_time = GETDATE();
        PRINT '>> Load Duration : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '------------------------------------------';

        SET @total_end = GETDATE();  -- End timer for the whole Bronze layer
        PRINT '===================================';
        PRINT 'Bronze Layer Load Completed';
        PRINT 'Total Bronze Layer Load Duration : ' + CAST(DATEDIFF(second, @total_start, @total_end) AS NVARCHAR) + ' seconds';
        PRINT '===================================';

    END TRY
    BEGIN CATCH
        PRINT '===================================';
        PRINT 'Error Occurred During Loading Bronze Layer';
        PRINT 'Error Message ' + ERROR_MESSAGE();
        PRINT 'Error Number  ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '===================================';
    END CATCH
END;

EXEC bronze.load_bronze;

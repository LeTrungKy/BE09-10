-- Run this ONLY if you already created the MyStore database with the old MyStore.sql
-- (a fresh MyStore.sql run already contains these changes). Safe to run more than once.
USE [MyStore];
GO

-- 1) stock column; existing products start with 50 units so they stay buyable
IF COL_LENGTH('dbo.Product', 'ProductStock') IS NULL
    ALTER TABLE dbo.Product ADD ProductStock int NOT NULL CONSTRAINT DF_Product_Stock DEFAULT (50);
GO

-- 2) stock can never be negative
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Product_Stock')
    ALTER TABLE dbo.Product ADD CONSTRAINT CK_Product_Stock CHECK (ProductStock >= 0);
GO

-- 3) the 50 above was only a back-fill: new products must state their own stock (default 0)
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = N'DF_Product_Stock')
BEGIN
    ALTER TABLE dbo.Product DROP CONSTRAINT DF_Product_Stock;
    ALTER TABLE dbo.Product ADD CONSTRAINT DF_Product_Stock DEFAULT (0) FOR ProductStock;
END
GO

-- 4) unique category names (skipped with a message if duplicates already exist - fix them first)
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_Category_CategoryName')
BEGIN
    IF EXISTS (SELECT CategoryName FROM dbo.Category GROUP BY CategoryName HAVING COUNT(*) > 1)
        PRINT N'Skipped UQ_Category_CategoryName: duplicate category names exist. Rename them, then run this script again.';
    ELSE
        ALTER TABLE dbo.Category ADD CONSTRAINT UQ_Category_CategoryName UNIQUE (CategoryName);
END
GO

SELECT N'Migration finished: Product.ProductStock added.' AS Result;
GO

-- 1. Create a database named "ecommerce_sales_data"
CREATE DATABASE IF NOT EXISTS ecommerce_sales_data
SHOW DATABASES
USE ecommerce_sales_data

-- 2. Create a table inside the database named "ecommerce_sales_data"
-- Command to generate SQL File: csvsql --dialect mysql --snifflimit 10000 Sales_Dataset.csv > Result.sql
CREATE TABLE `Sales_Dataset` (
	order_id VARCHAR(15) NOT NULL, 
	order_date DATE NOT NULL, 
	ship_date DATE NOT NULL, 
	ship_mode VARCHAR(14) NOT NULL, 
	customer_name VARCHAR(22) NOT NULL, 
	segment VARCHAR(11) NOT NULL, 
	state VARCHAR(36) NOT NULL, 
	country VARCHAR(32) NOT NULL, 
	market VARCHAR(6) NOT NULL, 
	region VARCHAR(14) NOT NULL, 
	product_id VARCHAR(16) NOT NULL, 
	category VARCHAR(15) NOT NULL, 
	sub_category VARCHAR(11) NOT NULL, 
	product_name VARCHAR(127) NOT NULL, 
	sales DECIMAL(38, 0) NOT NULL, 
	quantity DECIMAL(38, 0) NOT NULL, 
	discount DECIMAL(38, 3) NOT NULL, 
	profit DECIMAL(38, 5) NOT NULL, 
	shipping_cost DECIMAL(38, 2) NOT NULL, 
	order_priority VARCHAR(8) NOT NULL, 
	year DECIMAL(38, 0) NOT NULL
);

SHOW TABLES
DESC sales_dataset
-- 3. Load the data available in Sales_Dataset.csv file to the Sales_Dataset table
-- Famous error: MySQL is running at secure-file-private error
-- secure-file-priv="C:/ProgramData/MySQL/MySQL Server 8.0/Uploads"
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sales_Dataset.csv'
INTO TABLE Sales_Dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM Sales_Dataset
-- top 3 states with highest shipping cost
SELECT DISTINCT state,
SUM(shipping_cost) OVER (PARTITION BY state) AS total_Shipping_cost
FROM Sales_Dataset
ORDER BY total_Shipping_cost DESC
LIMIT 3;
SELECT state, SUM(shipping_cost) As total_Shipping_cost
FROM Sales_Dataset
GROUP BY state
order by total_Shipping_cost DESC LIMIT 3;
-- Data Analysis for an e-commerce company:
-- List the top 5 products by sales amount.
SELECT product_name FROM (SELECT product_name,SUM(sales) AS SALEofeachProduct FROM Sales_Dataset
GROUP BY product_name
ORDER BY SALEofeachProduct DESC LIMIT 5) as temp
-- optimized
SELECT product_name
FROM Sales_Dataset
GROUP BY product_name
ORDER BY SUM(sales) DESC
LIMIT 5;
-- Calculate the average profit margin per category.
SELECT * FROM Sales_Dataset
SELECT Category,AVG(profit) FROM Sales_Dataset
GROUP BY Category
-- Identify the top 3 states with the highest shipping costs.
SELECT state, SUM(shipping_cost) As total_Shipping_cost
FROM Sales_Dataset
GROUP BY state
order by total_Shipping_cost DESC LIMIT 3;
-- Calculate the total sales and profit for each market in the year 2012.
SELECT * From sales_dataset

SELECT 
    market,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM 
    Sales_Dataset
WHERE 
    year = 2012
GROUP BY 
    market;
-- Determine the percentage of orders that had a discount applied.
SELECT * From sales_dataset

WITH non_dis as(SELECT COUNT(*) as non FROM Sales_Dataset WHERE discount != 0.000),
total as(SELECT COUNT(*) as Total FROM Sales_Dataset)
SELECT (non*100/total.Total) FROM non_dis,total
-- OR
SELECT 
    (SELECT COUNT(*) FROM Sales_Dataset WHERE discount != 0.000) * 100.0 / 
    (SELECT COUNT(*) FROM Sales_Dataset)


-- Find the average shipping cost per order priority.
SELECT order_priority,AVG(shipping_cost) FROM sales_dataset
GROUP BY order_priority
-- List the products with a profit margin greater than 20%.
SELECT product_name, AVG(profit)*100/AVG(sales) as profit_margin
FROM Sales_Dataset
GROUP BY product_name
HAVING profit_margin > 20



-- Calculate the total quantity sold for each sub-category.
SELECT * From sales_dataset
SELECT sub_category,SUM(quantity)As Total_Quantity_Sold FROM Sales_Dataset
GROUP BY sub_category


 -- Calculate the total sales and profit for each year, using a CTE.
 -- Two CTE's
 WITH TS AS (SELECT year,SUM(Sales) as TotalSales
 FROM sales_dataset
 GROUP BY YEAR),
 P AS (SELECT year,AVG(profit) AS Profit
 FROM sales_dataset
 GROUP BY YEAR)
 SELECT p.year,TotalSales,Profit FROM TS,P
 WHERE P.YEAR =TS.YEAR
 -- One CTE
 WITH YearlyTotals AS (
    SELECT 
        year, 
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM 
        Sales_Dataset
    GROUP BY 
        year
)
SELECT 
    year, 
    total_sales, 
    total_profit
FROM 
    YearlyTotals;
  
 -- List the products with a profit margin greater than 20%, using a CTE.
 WITH PM AS(SELECT product_name, AVG(profit)*100/AVG(sales) as profit_margin
FROM Sales_Dataset
GROUP BY product_name)
SELECT * FROM PM WHERE profit_margin > 20
-- Sales over time
use [DataWarehouseAnalytics]
GO

SELECT 
order_date,
SUM(sales_amount) as total_sales
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date ASC


-- Aggregation on year level
SELECT 
YEAR (order_date)AS order_year,
SUM(sales_amount) as total_sales
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;

-- Aggregation on year level AND customers
SELECT 
YEAR (order_date) AS order_year,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) as Total_Quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;

-- Changes over Year - A high level Overview insight that helps with sytategic Decision Making


-- Change over month - Detailed Insight to Discover Seasonality in your data
SELECT 
Month (order_date)AS order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) as Total_Quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY Month(order_date)
ORDER BY Month(order_date) ASC;

-- Change over year and month (Output column is integer)
SELECT 
YEAR (order_date) AS order_year,
Month (order_date)AS order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) as Total_Quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR (order_date), Month(order_date)
ORDER BY YEAR (order_date), Month(order_date) ASC;

-- USING DATETRUNC fUNCTION outputs datet type
SELECT 
DATETRUNC (month, order_date) AS order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) as Total_Quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC (month, order_date) 
ORDER BY DATETRUNC (month, order_date);

-- USING FORMAT FUNCTION (Output column is string)
SELECT 
FORMAT(order_date, 'yyyy-MMM') AS order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as Total_Customers,
SUM(quantity) as Total_Quantity
FROM [gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date 
ORDER BY order_date;

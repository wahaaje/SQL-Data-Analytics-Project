-- Culumative Analysis is Aggeregarting data progressively over time
-- Helps us understand whether our business is growing or declining



-- Finding Running Total
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(order BY order_date) as running_total_sales
FROM
(
SELECT 
DATETRUNC(month,order_date) as order_date,
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) as t

-- Running total with Partitions
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(partition by order_date order BY order_date) as running_total_sales
FROM
(
SELECT 
DATETRUNC(month,order_date) as order_date,
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) as t

-- Moving average by year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(order BY order_date) as running_total_sales,
average_price,
avg(average_price) OVER(order BY order_date) as moving_average
FROM
(
SELECT 
DATETRUNC(year,order_date) as order_date,
SUM(sales_amount) as total_sales,
AVG(price) as average_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
) as t
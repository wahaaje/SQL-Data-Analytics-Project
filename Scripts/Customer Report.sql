/* 
===============================================================================================================
Customer Report
===============================================================================================================
Purpose:

- This report consolidates key customer metrics and behaviors

Highlights:
1- Gathers essential fields such as names, ages, and transaction details.
2- Segments customers into categories (VIP, Regular, New) and age groups.
3- Aggregates customer-level metrics:
	- total orders
	- total sales
	- total quantity purchased
	- total products
	- lifespan (in months)

4- Calculates valuable KPIs:
	- recency (months since last order)
	- average order value
	- average monthly spend
===============================================================================================================
*/

CREATE VIEW gold.report_customers AS
/* ------------------------------------------------------------------------------------------------------------
1)- Base Query:  Retreving the core columns from the Table
---------------------------------------------------------------------------------------------------------------*/

WITH base_query as (
/* ------------------------------------------------------------------------------------------------------------
1)- Base Query:  Retreving the core columns from the Table
---------------------------------------------------------------------------------------------------------------*/
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) as customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) as age
from gold.fact_sales as f
LEFT JOIN gold.dim_customers as c
on f.customer_key = c.customer_key
WHERE order_date IS NOT NULL
)
, customer_aggregation as (
/* ------------------------------------------------------------------------------------------------------------
2)- Customer Aggregation:  Summarizes key matrices at customer level 
---------------------------------------------------------------------------------------------------------------*/
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount)  as total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) as total_products,
	MAX(order_date) as last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
group by customer_key,customer_number,customer_name,age
)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 and 29 THEN '20-29'
		WHEN age BETWEEN 30 and 39 THEN '30-39'
		WHEN age BETWEEN 40 and 49 THEN '40-49'
		WHEN age BETWEEN 50 and 59 THEN '50-59'
		WHEN age BETWEEN 60 and 69 THEN '60-69'
		WHEN age BETWEEN 70 and 79 THEN '70-79'
		ELSE 'Above 80' END as Age_Category,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 then 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 then 'Regular'
	ELSE 'New' END as customer_segment,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan, 
	-- Compute Average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders END AS avg_order_value,

	-- Compute Average Monthly Spend (AMS)
	CASE WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan END as avg_monthly_spend
	FROM customer_aggregation


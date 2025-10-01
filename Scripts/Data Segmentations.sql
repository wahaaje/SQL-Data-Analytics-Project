/* Segement Product into cost ranges and 
count how many products fall into each segment */

WITH product_segment as
(
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
	WHEN cost BETWEEN 500 AND 1000 THEN ' 500 - 1000'
	ELSE 'Above 1000' END cost_range
FROM gold.dim_products 
) 

SELECT 
cost_range,
COUNT(product_key) as Total_Products
FROM product_segment
GROUP BY cost_range;


/*Group customers into three segments based on their spending behavior:

VIP: Customers with at least 12 months of history and spending more than €5,000.
Regular: Customers with at least 12 months of history but spending €5,000 or less.
New: Customers with a lifespan less than 12 months.

And find the total number of customers by each group. */
WITH customer_spending as
(
SELECT 
c.customer_key,
SUM(s.sales_amount) AS total_spending,
MIN(s.order_date) as first_order,
MAX(s.order_date) as last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
CASE WHEN lifespan >= 12 AND total_spending > 5000 then 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 then 'Regular'
	ELSE 'New' END as customer_segment,
COUNT(customer_key) as Total_customers 
FROM customer_spending
GROUP BY CASE WHEN lifespan >= 12 AND total_spending > 5000 then 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 then 'Regular'
	ELSE 'New' END ;

-- Another way of doing via subquery

WITH customer_spending as
(
SELECT 
c.customer_key,
SUM(s.sales_amount) AS total_spending,
MIN(s.order_date) as first_order,
MAX(s.order_date) as last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT 
customer_segment,
COUNT(customer_key) as Total_Customers
FROM (
	select
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 then 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 then 'Regular'
		ELSE 'New' END as customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY Total_Customers DESC	
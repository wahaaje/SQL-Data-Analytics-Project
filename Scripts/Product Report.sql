/*
============================================================================================================
Product Report
============================================================================================================
Purpose:

- This report consolidates key product metrics and behaviors.

Highlights:

- Gathers essential fields such as product name, category, subcategory, and cost.
- Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
Aggregates product-level metrics:
- total orders
- total sales
- total quantity sold
- total customers (unique)
- lifespan (in months)

Calculates valuable KPIs:

- recency (months since last sale)
- average order revenue (AOR)
- average monthly revenue
--------------------------------------------------------------------------------------------------------------
*/
CREATE VIEW gold.report_products as

With base_level as
(
SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
f.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
from gold.fact_sales as f
LEFT JOIN gold.dim_products as p 
on f.product_key = p.product_key
WHERE order_date IS NOT NULL
)
/* ------------------------------------------------------------------------------------------------------------
2)- Product Segmentation:  Summarizes key matrices at product level 
---------------------------------------------------------------------------------------------------------------*/
, product_segmentation as (
SELECT 
product_key,
product_name,
category,
subcategory,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
MAX(order_date) as last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount)  as total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount as float) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_level
GROUP BY product_key, product_name,category,subcategory, cost
)
/* ------------------------------------------------------------------------------------------------------------
3)- Final Query:  Combine all product resuls ino one output 
---------------------------------------------------------------------------------------------------------------*/

SELECT 
product_key,
product_name,
category,
subcategory,
lifespan,
last_sale_date,
DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_month,
CASE WHEN total_sales > 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer' END AS product_segment,
total_orders,
total_customers,
total_sales,
total_quantity,
avg_selling_price,
-- Compute Average order value (AOV)
CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders END AS avg_order_revenue,

--Average Monthly Revenue (AMR)
	CASE WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan END as avg_monthly_revenue
FROM product_segmentation

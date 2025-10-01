-- Performance Analysis
-- Comparing the current value to Target value
-- Helps us measure success to compare performance


-- Task: Analyze the yearly performance of products by comparing each products sales to both its average sales performance nad the previous years sales
use [DataWarehouseAnalytics]
GO

WITH yearly_product_sales as
(
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) as current_sales
FROM gold.fact_sales as f
LEFT JOIN gold.dim_products AS P
on f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (Partition by product_name) as avg_sales,
current_sales - AVG(current_sales) OVER (Partition by product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (Partition by product_name) > 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) OVER (Partition by product_name) < 0 THEN 'Below Average'
	ELSE 'Avg' END as Avg_Change,
LAG(current_sales) OVER (PARTITION BY product_name order by order_year) as py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name order by order_year) as py_diff,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name order by order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name order by order_year) < 0 THEN 'Decrease'
	ELSE 'No Change' END AS py_change
FROM yearly_product_sales
order by product_name, order_year
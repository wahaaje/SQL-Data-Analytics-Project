-- Part to whole Analysis - Proportional Analysis
-- Analyze how an individual part is performing compared to overall.
-- Allowing us to understand which caegory has the greatest impact on the business.

use [DataWarehouseAnalytics]
GO

-- What categories contribute the most to overall sales?
WITH category_sales as (
SELECT
p.category,
SUM(s.sales_amount) AS total_sales

FROM gold.fact_sales as s
LEFT JOIN gold.dim_products as p
on p.product_key = s.product_key

GROUP BY p.category
)
SELECT category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND((CAST(total_sales as FLOAT) / SUM(total_sales) OVER()) * 100,2), '%') as percentage_of_total
FROM category_sales 
ORDER BY total_sales DESC

-- Results shoe BIKES are the TOP performing categories and making 96% of total sales of our business
-- There is over reliance on a single category which is dangerous
-- helps us explain which category is best performing and under performing



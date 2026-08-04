
CREATE DATABASE CUSTOMER_SEGMENT ;
USE CUSTOMER_SEGMENT ;
CREATE TABLE sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    product_description VARCHAR(255),
    quantity INT,
    invoice_date DATETIME,
    unit_price DECIMAL(10,2),
    customer_id VARCHAR(20),
    country VARCHAR(100)
);
SHOW TABLES ;
SELECT *
FROM sales
LIMIT 20;
SHOW DATABASES;
USE customer_segmentation;

SHOW TABLES;
SELECT COUNT(*) AS total_rows
FROM sales;
SELECT *
FROM sales
LIMIT 10;
SELECT DISTINCT country
FROM sales
ORDER BY country;
SELECT COUNT(*) AS missing_customers
FROM sales
WHERE customer_id IS NULL
   OR customer_id = '';
   SELECT COUNT(*) AS cancelled_orders
FROM sales
WHERE invoice_no LIKE 'C%';
SELECT COUNT(*) AS invalid_quantity
FROM sales
WHERE quantity <= 0;
CREATE TABLE clean_sales AS

SELECT
    invoice_no,
    stock_code,
    product_description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    quantity * unit_price AS revenue

FROM sales

WHERE customer_id IS NOT NULL
AND customer_id <> ''
AND quantity > 0
AND unit_price > 0
AND invoice_no NOT LIKE 'C%';
SHOW TABLES ;
SELECT

SUM(revenue) AS total_revenue,

COUNT(DISTINCT invoice_no) AS total_orders,

COUNT(DISTINCT customer_id) AS total_customers,

ROUND(
SUM(revenue)/COUNT(DISTINCT invoice_no),
2
) AS average_order_value

FROM clean_sales;
SELECT

DATE_FORMAT(invoice_date,'%Y-%m') AS month,

SUM(revenue) AS revenue,

COUNT(DISTINCT invoice_no) AS orders

FROM clean_sales

GROUP BY month

ORDER BY month;
JULY
SELECT

country,

SUM(revenue) AS revenue,

COUNT(DISTINCT customer_id) AS customers

FROM clean_sales

GROUP BY country

ORDER BY revenue DESC
LIMIT 10;
SELECT

customer_id,

MAX(invoice_date) AS last_purchase,

COUNT(DISTINCT invoice_no) AS total_orders,

SUM(revenue) AS total_spent

FROM clean_sales

GROUP BY customer_id

ORDER BY total_spent DESC;

CREATE TABLE customer_rfm AS

SELECT

    customer_id,

    DATEDIFF(
        (SELECT MAX(invoice_date) FROM clean_sales),
        MAX(invoice_date)
    ) AS recency,

    COUNT(DISTINCT invoice_no) AS frequency,

    ROUND(SUM(revenue),2) AS monetary

FROM clean_sales

GROUP BY customer_id;
SELECT *
FROM customer_rfm
LIMIT 20;
CREATE TABLE customer_scores AS

SELECT

customer_id,

recency,

frequency,

monetary,

NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,

NTILE(5) OVER (ORDER BY frequency) AS frequency_score,

NTILE(5) OVER (ORDER BY monetary) AS monetary_score

FROM customer_rfm;

CREATE TABLE customer_segments AS

SELECT

*,

CASE

WHEN recency_score>=4
AND frequency_score>=4
AND monetary_score>=4

THEN 'Champions'

WHEN recency_score>=3
AND frequency_score>=4

THEN 'Loyal Customers'

WHEN recency_score>=4
AND frequency_score<=2

THEN 'New Customers'

WHEN recency_score<=2
AND frequency_score>=3

THEN 'At Risk'

WHEN recency_score=1
AND frequency_score=1

THEN 'Lost Customers'

ELSE 'Regular Customers'

END AS customer_segment

FROM customer_scores;
SELECT *
FROM customer_segments
LIMIT 30;
SELECT

customer_segment,

COUNT(*) AS customers

FROM customer_segments

GROUP BY customer_segment

ORDER BY customers DESC;

SELECT

customer_segment,

COUNT(*) AS customers,

ROUND(AVG(monetary),2) AS avg_customer_value,

ROUND(SUM(monetary),2) AS total_revenue

FROM customer_segments

GROUP BY customer_segment

ORDER BY total_revenue DESC;
SELECT *

FROM customer_segments

WHERE customer_segment='Champions'

ORDER BY monetary DESC

LIMIT 20;
SELECT *

FROM customer_segments

WHERE customer_segment='At Risk'

ORDER BY monetary DESC;

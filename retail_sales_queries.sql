-- Project Title: Retail Sales Analysis with SQL
-- Author: Abdullah Akintobi
-- Published On: October 30, 2024

-- -------------------------------------------------------
-- Data Modeling
-- -------------------------------------------------------

-- Create Database
CREATE DATABASE retail_sales_project;

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- -------------------------------------------------------
-- Data Exploration
-- -------------------------------------------------------

-- Preview the top 5 rows of the table 
SELECT *
FROM retail_sales
LIMIT 5;

-- Check the number of rows
SELECT COUNT(1) AS rows_num
FROM retail_sales;

-- Check for null values
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- -------------------------------------------------------
-- Data Cleaning
-- -------------------------------------------------------

-- Remove age and cogs columns
ALTER TABLE retail_sales
    DROP COLUMN age,
    DROP COLUMN cogs;

-- Preview table to confirm changes
SELECT *
FROM retail_sales
LIMIT 3;

-- Delete Null Values
DELETE FROM retail_sales
WHERE quantity IS NULL
    OR price_per_unit IS NULL
    OR total_sale IS NULL;

-- Confirm changes
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR total_sale IS NULL;

-- -------------------------------------------------------
-- Further Exploration
-- -------------------------------------------------------

-- Check the number of unique customers
SELECT COUNT(DISTINCT customer_id) AS customer_num
FROM retail_sales;

-- Check the list of unique categories
SELECT DISTINCT category AS unique_category
FROM retail_sales;

-- Check the number of sales in each category
SELECT category, COUNT(total_sale)
FROM retail_sales
GROUP BY category;

-- Check the number of sales by gender
SELECT gender, COUNT(total_sale)
FROM retail_sales
GROUP BY gender;

-- Check the purchase category by gender
SELECT category, gender, COUNT(total_sale)
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- -------------------------------------------------------
-- Data Analysis
-- -------------------------------------------------------

-- Q1: Retrieve the dates of the first and last sales transactions in the data.
WITH sales_date_order AS (
    SELECT sale_date,
           ROW_NUMBER() OVER (ORDER BY sale_date ASC) AS row_num,
           ROW_NUMBER() OVER (ORDER BY sale_date DESC) AS rev_row_num
    FROM retail_sales
)
SELECT CASE
           WHEN row_num = 1 THEN 'First Sale'
           WHEN rev_row_num = 1 THEN 'Last Sale'
           ELSE 'Other Sale'
       END AS sales_order,
       sale_date
FROM sales_date_order
WHERE row_num = 1 OR rev_row_num = 1;

-- Q2: Retrieve all columns for sales transactions made on November 5, 2022.
SELECT *
FROM retail_sales
WHERE EXTRACT(DAY FROM sale_date) = 5
    AND EXTRACT(MONTH FROM sale_date) = 11
    AND EXTRACT(YEAR FROM sale_date) = 2022;

-- Q3: Retrieve all transactions in November 2022 where the category is 'Clothing' and the quantity sold exceeds 2.
SELECT *
FROM retail_sales
WHERE EXTRACT(MONTH FROM sale_date) = 11
    AND EXTRACT(YEAR FROM sale_date) = 2022
    AND category = 'Clothing'
    AND quantity > 2;

-- Q4: Calculate the total sales amount for each category.
SELECT category, SUM(total_sale)
FROM retail_sales
GROUP BY category;

-- Q5: Determine the total number of transactions for each category, broken down by gender.
SELECT category, gender, COUNT(transactions_id) AS transactions_made
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Q6: Identify all transactions where the total sales amount is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q7: Identify the top 3 hours of the day with the highest number of transactions, along with the transaction count for each hour.
SELECT EXTRACT(HOUR FROM sale_time) AS sales_hour,
       COUNT(transactions_id) AS tras_num
FROM retail_sales
GROUP BY sales_hour
ORDER BY tras_num DESC
LIMIT 3;

-- Q8: Calculate the average sales amount for each month and identify the best-selling month each year.
WITH sale_by_year AS (
    SELECT EXTRACT(YEAR FROM sale_date) AS sale_year,
           EXTRACT(MONTH FROM sale_date) AS sale_month,
           ROUND(CAST(AVG(total_sale) AS numeric), 2) AS net_sale,
           RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date)
                        ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY sale_year, sale_month
)
SELECT sale_year, sale_month, net_sale
FROM sale_by_year
WHERE rank = 1;

-- Q9: Identify the top 5 customers based on the highest total sales amount.
SELECT customer_id, SUM(total_sale) AS total_sale_by_cus
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale_by_cus DESC
LIMIT 5;

-- Q10: Count the number of unique customers who made purchases in each category.
SELECT category, COUNT(DISTINCT(customer_id)) AS cus_num
FROM retail_sales
GROUP BY category;

-- Q11: Categorize each order by shift—Morning (before 12:00 PM), Afternoon (12:00 PM to 5:00 PM), and Evening (after 5:00 PM)—and determine the number of orders per shift.
WITH sales_time AS (
    SELECT *,
           CASE
               WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
               WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
               ELSE 'Evening'
           END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(transactions_id) AS total_order
FROM sales_time
GROUP BY shift;

-- END OF PROJECT

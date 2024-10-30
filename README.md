# Retail Sales Analysis with SQL

**Author**: Abdullah Akintobi   
**DBMS**: PostgreSQL    
**Date Published**: October 30, 2024

---

## Project Overview

This project utilizes PostgreSQL to explore and analyze sales data within a retail context. The project is designed to answer key business questions, clean and model data, and ultimately provide insights into customer behaviour, sales trends, and categorical performance. The data analysis approach is structured into sections covering **Data Modeling**, **Data Exploration**, **Data Cleaning**, **Further Exploration**, and **Data Analysis**.

---

## 1. Data Modeling

### Database and Table Creation

- **Database**: Created a dedicated database called `retail_sales_project`.
- **Table**: Created the `retail_sales` table with key columns including:
  - `transactions_id`: Primary key for transactions.
  - `sale_date` and `sale_time`: Timestamp details for each sale.
  - `customer_id`, `gender`, `category`, `quantity`, and `total_sale` to capture transaction and demographic details.
```sql
CREATE DATABASE retail_sales_project;

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
```
---

## 2. Data Exploration

### Basic Data Insights

1. **Preview Data**: Selected the top 5 rows to understand the initial data layout. 
```sql
SELECT * FROM retail_sales LIMIT 5;
```
2. **Row Count**: Checked total rows to confirm data volume.
```sql
SELECT COUNT(1) AS rows_num FROM retail_sales;
```
3. **Null Check**: Verified null values across all fields to ensure data integrity.
```sql
SELECT * FROM retail_sales WHERE 
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
    customer_id IS NULL OR gender IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR 
    total_sale IS NULL;
```
---

## 3. Data Cleaning

### Column Modifications and Null Handling

- **Column Removal**: Dropped `age` and `cogs` columns as they were deemed irrelevant to the analysis.
```sql
ALTER TABLE retail_sales DROP COLUMN age, DROP COLUMN cogs;
```
- **Null Deletion**: Removed rows where critical fields (`quantity`, `price_per_unit`, `total_sale`) contained null values.
```sql
DELETE FROM retail_sales WHERE quantity IS NULL OR price_per_unit IS NULL OR total_sale IS NULL;
```
- **Confirmation**: Verified the absence of nulls after cleaning operations.
```sql
SELECT * FROM retail_sales WHERE 
    transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
    customer_id IS NULL OR gender IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR total_sale IS NULL;
```
---

## 4. Further Exploration

### Exploratory Analysis

- **Unique Customers**: Counted distinct `customer_id` values to assess customer base.
```sql
SELECT COUNT(DISTINCT customer_id) AS customer_num FROM retail_sales;
```
- **Unique Categories**: Listed unique sales categories.
```sql
SELECT DISTINCT category AS unique_category FROM retail_sales;
```
- **Category Sales**: Counted transactions per category.
```sql
SELECT category, COUNT(total_sale) FROM retail_sales GROUP BY category;
```
- **Gender Breakdown**: Analyzed sales distribution by gender.
```sql
SELECT gender, COUNT(total_sale) FROM retail_sales GROUP BY gender;
```
- **Purchase Category by Gender**: Examined cross-analysis of category and gender to observe preferences.
```sql
SELECT category, gender, COUNT(total_sale) FROM retail_sales GROUP BY category, gender ORDER BY category;
```

---

## 5. Data Analysis

### Key Analytical Queries

Below are the specific business questions addressed with SQL queries and their corresponding insights:

1. **Sales Period**: Retrieved dates of the first and last sales transactions.
```sql
WITH sales_date_order AS (
    SELECT sale_date,
           ROW_NUMBER() OVER (ORDER BY sale_date ASC) AS row_num,
           ROW_NUMBER() OVER (ORDER BY sale_date DESC) AS rev_row_num
    FROM retail_sales
)
SELECT CASE WHEN row_num = 1 THEN 'First Sale'
            WHEN rev_row_num = 1 THEN 'Last Sale'
            ELSE 'Other Sale' END AS sales_order,
       sale_date
FROM sales_date_order
WHERE row_num = 1 OR rev_row_num = 1;
```
2. **Specific Date Transactions**: Extracted all transactions made on November 5, 2022.
```sql
SELECT * FROM retail_sales WHERE 
    EXTRACT(DAY FROM sale_date) = 5 AND 
    EXTRACT(MONTH FROM sale_date) = 11 AND 
    EXTRACT(YEAR FROM sale_date) = 2022;
```
3. **Category-Specific Transactions**: Identified all November 2022 transactions where `category` is 'Clothing' with `quantity` greater than 2.
```sql
SELECT * FROM retail_sales WHERE 
    EXTRACT(MONTH FROM sale_date) = 11 AND 
    EXTRACT(YEAR FROM sale_date) = 2022 AND 
    category = 'Clothing' AND quantity > 2;
```
4. **Total Sales per Category**: Summed `total_sale` for each category.
```sql
SELECT category, SUM(total_sale) FROM retail_sales GROUP BY category;
```
5. **Gender-Category Breakdown**: Counted transactions per category broken down by gender.
```sql
SELECT category, gender, COUNT(transactions_id) AS transactions_made FROM retail_sales GROUP BY category, gender ORDER BY category;
```
6. **High-Value Transactions**: Isolated transactions where `total_sale` exceeded 1000.
```sql
SELECT * FROM retail_sales WHERE total_sale > 1000;
```
7. **Top Sales Hours**: Identified the top 3 hours of the day with the highest transaction volume.
```sql
SELECT EXTRACT(HOUR FROM sale_time) AS sales_hour, COUNT(transactions_id) AS tras_num FROM retail_sales GROUP BY sales_hour ORDER BY tras_num DESC LIMIT 3;
```
8. **Monthly Sales Performance**: Calculated monthly average sales and identified the best-performing month each year.
```sql
WITH sale_by_year AS (
    SELECT EXTRACT(YEAR FROM sale_date) AS sale_year,
           EXTRACT(MONTH FROM sale_date) AS sale_month,
           ROUND(CAST(AVG(total_sale) AS numeric), 2) AS net_sale,
           RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY sale_year, sale_month
)
SELECT sale_year, sale_month, net_sale FROM sale_by_year WHERE rank = 1;
```
9. **Top Customers**: Listed top 5 customers by `total_sale`.
```sql
SELECT customer_id, SUM(total_sale) AS total_sale_by_cus FROM retail_sales GROUP BY customer_id ORDER BY total_sale_by_cus DESC LIMIT 5;
```
10. **Unique Customers by Category**: Counted unique customers per category.
```sql
SELECT category, COUNT(DISTINCT(customer_id)) AS cus_num FROM retail_sales GROUP BY category;
```
11. **Sales Shifts**: Classified orders by time-based shifts (Morning, Afternoon, Evening) and counted orders within each shift.
```sql
WITH sales_time AS (
    SELECT *,
           CASE WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
                WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
                ELSE 'Evening' END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(transactions_id) AS total_order FROM sales_time GROUP BY shift;
```

---

## Summary Insights

This analysis provides insights that can inform business strategies:

- **Customer Behavior**: The data explores unique customer counts and the top-performing customers, identifying repeat customers and potential loyalists.
- **Category Insights**: Breakdown of transactions by category and analysis of gender-based purchasing behaviour suggests tailored marketing opportunities.
- **Time-based Trends**: Analyzing transactions by shift and identifying peak sales hours could assist in staffing and operational planning.
- **High-Value Sales and Monthly Trends**: Insights from high-value sales and monthly averages highlight peak sales periods, enabling inventory and promotional alignment.

---

## Conclusion

This project demonstrates the use of SQL to conduct thorough data cleaning, exploratory analysis, and insights derivation within a retail sales dataset. The structure and modularity of SQL queries provide reusable code for further analysis, making it adaptable for ongoing data-driven decision-making in a retail context.

---

## About this project

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions or feedback or would like to collaborate, feel free to get in touch!

### Contact
- **Linkedin**: [Abdullah Akintobi](https://www.linkedin.com/in/abdullahakintobi/)
- **X**: [@AkintobiAI](https://x.com/AkintobiAI)

Thank you for your time, and I look forward to connecting with you!


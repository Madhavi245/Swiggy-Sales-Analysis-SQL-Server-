🍽️ Swiggy Sales Analysis – SQL Server Project

This project focuses on analyzing Swiggy food delivery sales data using SQL Server Management Studio (SSMS). The goal is to transform raw operational data into a structured analytical model and generate meaningful business insights through SQL queries.

The project covers data cleaning, validation, dimensional modelling (Star Schema), and KPI analysis to support efficient reporting and decision-making.

📌 Business Objectives

The main objectives of this project are:

Ensure data quality and reliability through cleaning and validation.

Transform the raw dataset into a Star Schema for efficient analytics.

Generate key performance indicators (KPIs) and business insights using SQL queries.

Enable better understanding of food delivery trends, restaurant performance, and customer spending patterns.

🧹 Data Cleaning & Validation

The raw table swiggy_data contains food delivery records including state, city, restaurant, cuisine category, dishes, prices, and ratings.

Data quality checks were performed to ensure accurate analysis:

1️⃣ Null Value Check

Identify missing values in important columns such as:

State

City

Order_Date

Restaurant_Name

Location

Category

Dish_Name

Price_INR

Rating

Rating_Count

2️⃣ Blank Value Detection

Detect empty or blank string values that could affect reporting accuracy.

3️⃣ Duplicate Detection

Duplicates were identified by grouping records using all important business columns.

4️⃣ Duplicate Removal

The ROW_NUMBER() window function was used to remove duplicate rows while keeping a single valid record for each order.

⭐ Dimensional Modelling (Star Schema)

To optimize analytical performance, the cleaned dataset was transformed into a Star Schema data model.

Instead of keeping all information in a single large table, descriptive attributes were separated into dimension tables, while measurable values were stored in a central fact table.

Dimension Tables

dim_date → Year, Month, Quarter, Week

dim_location → State, City, Location

dim_restaurant → Restaurant Name

dim_category → Food Category / Cuisine

dim_dish → Dish Name

Fact Table

fact_swiggy_orders

Price_INR

Rating

Rating_Count

Foreign keys linking to all dimension tables

This model improves:

Query performance

Data clarity

Scalability for reporting and BI dashboards

📊 Key Performance Indicators (KPIs)

After building the analytical model, SQL queries were used to calculate important business metrics.

Basic KPIs

Total Orders

Total Revenue (INR Million)

Average Dish Price

Average Rating

📈 Business Analysis
📅 Date-Based Analysis

Monthly order trends

Quarterly order trends

Year-wise growth analysis

Day-of-week order patterns

📍 Location-Based Analysis

Top 10 cities by order volume

Revenue contribution by state

🍛 Food Performance Analysis

Top 10 restaurants by total orders

Top food categories (Indian, Chinese, etc.)

Most ordered dishes

Cuisine performance based on orders and average ratings

💰 Customer Spending Insights

Orders were grouped into spending ranges:

Under 100 INR

100–199 INR

200–299 INR

300–499 INR

500+ INR

This helps understand customer purchase behavior.

⭐ Ratings Analysis

Analysis of rating distribution across the 1–5 rating scale to evaluate dish and restaurant performance.

🛠 Tools & Technologies

SQL Server Management Studio (SSMS)

SQL

Data Cleaning & Validation

Dimensional Modelling (Star Schema)

Analytical SQL Queries

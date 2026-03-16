SELECT * FROM swiggy_data

--Data Cleaning and Validation
--Null values Check
SELECT 
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_Restaurant_Name,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_Location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_Category ,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_Dish_Name,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_Price_INR,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_Rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_Rating_Count
FROM swiggy_data;

--Blank/Emply check 
SELECT * 
	FROM swiggy_data
	WHERE State =' ' OR City=' ' OR Restaurant_Name=' ' OR Location= ' ' OR Category=' ' OR Dish_Name=' ' OR Price_INR=' ' OR Rating=' ' ;
	
--Duplicate Check
SELECT 
	State, City , Order_Date, Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count, COUNT(*) as CNT
From swiggy_data
GROUP BY 
State, City , Order_Date, Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
Having COUNT(*) >1

--Remove Duplicates
WITH CTE AS(
SELECT*, ROW_NUMBER() OVER (
	PARTITION BY State, City , Order_Date, Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
ORDER BY (SELECT NULL)
)AS rn 
FROM swiggy_data)
DELETE FROM CTE WHERE rn>1

--Create schema / Dimension Tables
--Date Table
CREATE TABLE dim_date(
	Date_id INT IDENTITY (1,1) PRIMARY KEY,
	Full_Date DATE,
	Year INT,
	Month INT,
	Month_Name varchar(20),
	Quarter INT,
	Day INT,
	Week INT
	);

--Location Table
CREATE TABLE dim_location(
	Location_id INT IDENTITY (1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
	);

-- Resturant Table
CREATE TABLE dim_restaurant(
	Restaurant_id INT IDENTITY (1,1) PRIMARY KEY,
	restaurant_name VARCHAR(200)
	);

--Category Table 
CREATE TABLE dim_category(
	Category_id INT IDENTITY (1,1) PRIMARY KEY,
	category VARCHAR(200)
	);

--Dish Table
CREATE TABLE dim_dish(
	Dish_id INT IDENTITY (1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
	);

--Fact Table 
CREATE TABLE fact_swiggy_orders(
	Order_id INT IDENTITY (1,1) PRIMARY KEY,
	Date_id INT,
	Price_INR DECIMAL(10,2),
	Rating DECIMAL (4,2),
	Rating_Count INT,

	Location_id INT,
	Restaurant_id INT,
	Category_id INT,
	Dish_id INT,

	FOREIGN KEY (Date_id) REFERENCES dim_date(Date_id),
	FOREIGN KEY (Location_id) REFERENCES dim_location(Location_id),
	FOREIGN KEY (Restaurant_id) REFERENCES dim_restaurant(Restaurant_id),
	FOREIGN KEY (Category_id) REFERENCES dim_category(Category_id),
	FOREIGN KEY (Dish_id) REFERENCES dim_dish(Dish_id)
);


--Inset Data 
--Insert Data to Date Table
INSERT INTO dim_date (Full_Date,Year,Month,Month_Name,Quarter,Day,Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH,Order_Date),
	DATEPART(QUARTER,Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK,Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL;

-- Insert data to Location Table
INSERT INTO dim_location (State,City,Location)
SELECT DISTINCT 
	State,
	City,
	Location
FROM swiggy_data;

--Insert data into  Resturant Table
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT 
	Restaurant_name
FROM swiggy_data;

--Insert data into Category Table
INSERT INTO dim_category (Category)
SELECT DISTINCT 
	Category
FROM swiggy_data;

--Insert data into Dish Table
INSERT INTO dim_dish (Dish_Name)
SELECT DISTINCT 
	Dish_Name
FROM swiggy_data;

--Insert data into Fact Table
INSERT INTO fact_swiggy_orders (
Date_id,
Price_INR,
Rating,
Rating_Count,
Location_id,
Restaurant_id,
Category_id,
Dish_id
)
SELECT 
	dd.Date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,

	dl.Location_id,
	dr.Restaurant_id,
	dc.Category_id,
	dsh.Dish_id
FROM swiggy_data s

JOIN dim_date dd
	ON dd.Full_Date=s.Order_Date

JOIN dim_location dl
	ON dl.State=s.State
	AND dl.City=s.City
	AND dl.Location=s.Location

JOIN dim_restaurant dr
	ON dr.restaurant_Name=s.Restaurant_Name

JOIN dim_category dc
	ON dc.category = s.Category

JOIN dim_dish dsh
	ON dsh.Dish_Name=s.Dish_Name;

SELECT * FROM fact_swiggy_orders

--Select all 

SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id=d.date_id
JOIN dim_location l ON f.location_id=l.location_id
JOIN dim_restaurant r ON f.restaurant_id=r.restaurant_id
JOIN dim_category c ON f.category_id=c.category_id
JOIN dim_dish di ON f.dish_id=di.dish_id;

--KPI Calculations
--Total Orders 
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders;

--Total Revenue
Select FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000, 'N2') + ' INR Million'  AS Total_Revenue
FROM fact_swiggy_orders;

--Average Dish Price
Select FORMAT(AVG(CONVERT(FLOAT,Price_INR)),'N2') + 'INR Million' AS Average_Dish_Price
FROM fact_swiggy_orders;

-- Average Rating
SELECT AVG(Rating)
FROM fact_swiggy_orders;


-- Monthly Trends
SELECT
	d.year,
	d.month_name,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
	ON f.date_id=d.date_id
GROUP BY 
	d.year,
	d.month,
	d.month_name	
ORDER BY 
	d.year,
	d.month;

--Quaterly Trends
SELECT
	d.year,
	d.Quarter,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
	ON f.date_id=d.date_id
GROUP BY 
	d.year,
	d.quarter	
ORDER BY 
	d.year,
	d.quarter;

--Yearly Orders
SELECT
	d.year,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
	ON f.date_id=d.date_id
GROUP BY 
	d.year;

-- Day of week
SELECT
	DATENAME(weekday,d.full_date) AS Day_Name,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d 
	ON f.date_id=d.date_id
GROUP BY 
	DATENAME(weekday,d.full_date),
	DATEPART(weekday,d.full_date)
ORDER BY 
	DATEPART(weekday,d.full_date);

--Top 10  cities by orders
SELECT TOP 10
	City,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l 
	ON f.location_id=l.location_id
GROUP BY 
	City 
ORDER BY COUNT(*) DESC

--Revenue contribution by state
SELECT
	State,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l 
	ON f.location_id=l.location_id
GROUP BY 
	State 
ORDER BY FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') DESC

--Top 10 restaurant by  order
SELECT TOP 10
	restaurant_name,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_restaurant r
	ON f.restaurant_id=r.restaurant_id
GROUP BY 
	restaurant_name
ORDER BY COUNT(*) DESC

--Top category by orders
SELECT 
	category,
	COUNT(*) AS Total_Orders,
	FORMAT(SUM(CONVERT(FLOAT,price_INR))/1000000,'N2') AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_category c
	ON f.category_id=c.category_id
GROUP BY 
	category
ORDER BY COUNT(*) DESC

--Top 3 dish
SELECT Top 3
	Dish_Name,
	COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_dish ds
	ON f.dish_id=ds.dish_id
GROUP BY 
	Dish_Name
ORDER BY COUNT(*) DESC

--Cuising Performance
SELECT
	Category,
	COUNT(*) AS Total_Orders,
	AVG(Rating) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_category c
	ON f.category_id=c.category_id
GROUP BY 
	Category
ORDER BY 
	Total_Orders DESC

--Customer Spending Insights
SELECT
	CASE
		WHEN CONVERT(FLOAT,price_INR)<100 THEN 'Under 100'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END
	AS price_range,
	COUNT(*) AS Total_orders
FROM fact_swiggy_orders
GROUP BY
	CASE
		WHEN CONVERT(FLOAT,price_INR)<100 THEN 'Under 100'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN CONVERT(FLOAT,price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END
ORDER BY Total_orders DESC;

--Rating count distribution
SELECT 
	rating,
	COUNT(*) as rating_count
FROM fact_swiggy_orders
GROUP BY rating
ORDER BY rating;


select * from dim_category

--                                                                              "TARGET CASE STUDY"



/* Target is a globally renowned brand and a prominent retailer in the United States. Target makes itself a preferred shopping destination by offering outstanding value, inspiration, 
innovation and an exceptional guest experience that no other retailer can deliver.
This particular business case focuses on the operations of Target in Brazil and provides insightful information about 100,000 orders placed between 2016 and 2018. 
The dataset offers a comprehensive view of various dimensions including the order status, price, payment & freight performance, customer location, product attributes, customer reviews.

By analyzing this extensive dataset, it becomes possible to gain valuable insights into Target's operations in Brazil. The information can shed light on various aspects of the business, 
such as order processing, pricing strategies, payment and shipping efficiency, customer demographics, product characteristics, and customer satisfaction levels. */


--1. Data type of all columns in the "customers" table.
-- Code:

SELECT column_name, data_type
FROM `scaler-dsml-sql-tutorial.Target_Company_Data`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'customers';



--2. Get the time range between which the orders were placed.
-- Code:

SELECT MIN(order_purchase_timestamp) AS first_order_in_dataset,
MAX(order_purchase_timestamp) AS last_order_in_dataset
FROM `Target_Company_Data.orders`;



-- 3. Count the Cities & States of customers who ordered during the given period.
-- Code:

SELECT COUNT(DISTINCT c.customer_city) AS count_of_customers_cities,
COUNT(DISTINCT c.customer_state) AS count_of_customers_states
FROM `Target_Company_Data.customers` c
INNER JOIN `Target_Company_Data.orders` o
ON c.customer_id = o.customer_id;



-- II. In-depth Exploration:
-- 1. Is there a growing trend in the no. of orders placed over the past years ?
-- Code:

WITH CTE AS (
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS Past_Years, COUNT(order_id) AS
number_of_orders
FROM `Target_Company_Data.orders`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
)
SELECT Past_Years,number_of_orders,
LAG(number_of_orders) OVER (ORDER BY Past_Years) AS previous_year_orders,
CONCAT(ROUND((number_of_orders - LAG(number_of_orders) OVER (ORDER BY Past_Years)) /
LAG(number_of_orders) OVER (ORDER BY Past_Years)*100,2 ), '%') AS growth_percentage
FROM CTE
ORDER BY Past_Years;



-- 2. Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
-- Code:

SELECT *
FROM
(SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
FORMAT_DATETIME("%B",order_purchase_timestamp) AS month_name,
EXTRACT(MONTH FROM order_purchase_timestamp) AS month_number,
COUNT(order_id) AS number_of_orders
FROM `Target_Company_Data.orders`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp),
FORMAT_DATETIME("%B",order_purchase_timestamp), EXTRACT(MONTH FROM order_purchase_timestamp)
)
ORDER BY year, month_number;



/* 3. During what time of the day, do the Brazilian customers mostly place their orders? (Dawn,
Morning, Afternoon or Night)
● 0-6 hrs : Dawn
● 7-12 hrs : Mornings
● 13-18 hrs : Afternoon
● 19-23 hrs : Night */
-- Code:

WITH CTE AS (
SELECT CASE WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 00 AND 06 THEN 'Dawn'
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 07 AND 12 THEN 'Mornings'
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
ELSE 'Night'
END AS Day_time, order_id
FROM `Target_Company_Data.orders`
)
SELECT Day_time, COUNT(order_id) AS number_of_orders
FROM CTE
GROUP BY Day_time
ORDER BY Day_time DESC;




/* III. Evolution of E-commerce orders in the Brazil region:

1. Get the month on month no. of orders placed in each state.*/
--Code:

WITH CTE AS (
SELECT FORMAT_DATETIME("%B", o.order_purchase_timestamp) AS month_name,
EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_number, c.customer_state, o.order_id
FROM `Target_Company_Data.customers` c
INNER JOIN `Target_Company_Data.orders` o
ON c.customer_id = o.customer_id
)
SELECT month_number, month_name,customer_state , COUNT(order_id) as number_of_orders
FROM CTE
GROUP BY month_number, month_name,customer_state
ORDER BY number_of_orders DESC;



-- 2. How are the customers distributed across all the states?
-- Code:

SELECT COUNT(customer_unique_id) AS Number_of_customers, customer_state as States
FROM `Target_Company_Data.customers`
GROUP BY customer_state
ORDER BY Number_of_customers DESC;




/* IV. Impact on Economy: Analyze the money movement by e-commerce by looking at order prices,
freight and others.

1. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug
only). */
-- Code:

WITH CTE AS (
SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month,
ROUND(SUM(p.payment_value)) AS total_payment
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.payments` p
ON o.order_id = p.order_id
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp), EXTRACT(MONTH FROM
o.order_purchase_timestamp)
)
SELECT t1.Month, t1.Year_2017, t2.Year_2018,
CONCAT(ROUND(((t2.Year_2018 - t1.Year_2017) / t1.Year_2017) * 100, 2) , '%') AS
Percentage_increase
FROM
(SELECT total_payment AS Year_2017, Month FROM CTE
WHERE year = 2017 and Month BETWEEN 1 and 8) t1
INNER JOIN
(SELECT total_payment AS Year_2018, Month FROM CTE
WHERE year = 2018 and Month BETWEEN 1 and 8) t2
ON t1.Month = t2.Month
ORDER BY t1.Month;

-- OR

-- Code:

SELECT CONCAT((
SUM(CASE WHEN EXTRACT(year FROM order_purchase_timestamp) = 2018 AND EXTRACT(MONTH FROM
order_purchase_timestamp) BETWEEN 1 AND 8 THEN payment_value ELSE 0 END)
-
SUM(CASE WHEN EXTRACT(year FROM order_purchase_timestamp) = 2017 AND EXTRACT(MONTH FROM
order_purchase_timestamp) BETWEEN 1 AND 8 THEN payment_value ELSE 0 END))
/
SUM(CASE WHEN EXTRACT(year FROM order_purchase_timestamp) = 2017 AND EXTRACT(MONTH FROM
order_purchase_timestamp) BETWEEN 1 AND 8 THEN payment_value
ELSE 0 END) * 100, '%') as percentage_increase
FROM `Target_Company_Data.orders` o inner join `Target_Company_Data.payments` p
ON o.order_id = p.order_id
WHERE EXTRACT(year FROM order_purchase_timestamp) BETWEEN 2017 AND 2018
AND EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8;



-- 2. Calculate the Total & Average value of order price for each state.
-- Code:

WITH CTE AS
(SELECT c.customer_state, ROUND(SUM(i.price),2) AS total_price, ROUND(AVG(i.price),2) AS
average_price
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.order_items` i
ON o.order_id = i.order_id
INNER JOIN `Target_Company_Data.customers` c
ON c.customer_id = o.customer_id
GROUP BY c.customer_state)
SELECT t1.customer_state AS top_total_price_customer_states, t1.total_price,
t2.customer_state AS top_average_price_customer_states, t2.average_price
FROM
(SELECT ROW_NUMBER() OVER(ORDER BY total_price DESC) AS r1, customer_state, total_price
FROM CTE) t1
INNER JOIN
(SELECT ROW_NUMBER() OVER(ORDER BY average_price DESC) AS r2, customer_state, average_price
FROM CTE) t2
ON t1.r1 = t2.r2;


-- 3. Calculate the Total & Average value of order freight for each state
-- Code:

WITH CTE AS
(SELECT c.customer_state, ROUND(SUM(i.freight_value),2) AS total_freight_value,
ROUND(AVG(i.freight_value),2) AS average_freight_value
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.order_items` i
ON o.order_id = i.order_id
INNER JOIN `Target_Company_Data.customers` c
ON c.customer_id = o.customer_id
GROUP BY c.customer_state)
SELECT t1.customer_state AS highest_total_freight_value_states,
t1.total_freight_value,t2.customer_state
AS highest_average_freight_value_states, t2.average_freight_value
FROM
(SELECT ROW_NUMBER() OVER(ORDER BY total_freight_value DESC) AS r1, customer_state,
total_freight_value FROM CTE) t1
INNER JOIN
(SELECT ROW_NUMBER() OVER(ORDER BY average_freight_value DESC) AS r2, customer_state,
average_freight_value FROM CTE) t2
ON t1.r1 = t2.r2;



-- V. Analysis based on sales, freight and delivery time.

/* 1. Find the no. of days taken to deliver each order from the order’s purchase date as delivery
time. Also, calculate the difference (in days) between the estimated & actual delivery date of
an order. Do this in a single query. */
-- Code:

SELECT order_id,order_purchase_timestamp AS Order_Delivery_date,
order_estimated_delivery_date AS Expected_Delivery_date,
order_delivered_customer_date AS Actual_Delivery_date,
DATETIME_DIFF(order_estimated_delivery_date,order_purchase_timestamp ,Day) AS
Expected_number_of_days,
DATETIME_DIFF (order_delivered_customer_date, order_purchase_timestamp, day) AS
diff_Delivery_from_Order,
DATETIME_DIFF(order_estimated_delivery_date, order_delivered_customer_date, day) AS
diff_from_Estimation
FROM `Target_Company_Data.orders`
WHERE DATETIME_DIFF(order_delivered_customer_date, order_purchase_timestamp, day) IS NOT NULL
ORDER BY diff_from_Estimation;


-- 2. Find out the top 5 states with the highest & lowest average freight value.
-- Code:

WITH CTE AS
(SELECT c.customer_state, ROUND(AVG(i.freight_value),2) AS avg_value
FROM `Target_Company_Data.order_items` i
INNER JOIN `Target_Company_Data.orders` o
ON i.order_id = o.order_id
INNER JOIN `Target_Company_Data.customers` c
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
)
SELECT c1.customer_state AS top_5_customer_state, c1.avg_value AS top_5_freight_value,
c2.customer_state AS least_5_customer_state, c2.avg_value AS least_5_freight_value FROM
(SELECT ROW_NUMBER() OVER(ORDER BY avg_value DESC) AS r1, customer_state, CTE.avg_value FROM
CTE) c1
INNER JOIN
(SELECT ROW_NUMBER() OVER(ORDER BY avg_value ASC) AS r2, customer_state, CTE.avg_value FROM CTE)
c2
ON c1.r1 = c2.r2
WHERE r1 <=5 AND r2 <=5;



-- 3. Find out the top 5 states with the highest & lowest average delivery time.
-- Code:

WITH CTE AS
(SELECT c.customer_state, ROUND(AVG(TIMESTAMP_DIFF (order_delivered_customer_date,
order_purchase_timestamp, day)),2) AS delivery_timestamp_in_days
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.customers` c
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
)
SELECT c1.customer_state AS top5_delivery_time_states, c1.delivery_timestamp_in_days AS
top_avg_delivery_time, c2.customer_state AS least5_delivery_time_states,
c2.delivery_timestamp_in_days AS least_avg_delivery_time
FROM
(SELECT ROW_NUMBER() OVER(ORDER BY delivery_timestamp_in_days DESC) AS r1, customer_state,
CTE.delivery_timestamp_in_days FROM CTE) c1
INNER JOIN
(SELECT ROW_NUMBER() OVER(ORDER BY delivery_timestamp_in_days ASC) AS r2, customer_state,
CTE.delivery_timestamp_in_days FROM CTE) c2
ON c1.r1 = c2.r2
WHERE r1 <=5 AND r2 <=5;



/* 4. Find out the top 5 states where the order delivery is really fast as compared to the estimated
date of delivery.*/ 
-- Code :

WITH CTE AS
(SELECT c.customer_state,
ROUND(AVG(TIMESTAMP_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date,
DAY)), 2) AS Avg_actual_difference_in_days
FROM `Target_Company_Data.orders` AS o
INNER JOIN `Target_Company_Data.customers` AS c
ON o.customer_id = c.customer_id
WHERE order_delivered_customer_date is NOT NULL AND order_estimated_delivery_date is NOT NULL
GROUP BY c.customer_state)
SELECT customer_state, Avg_actual_difference_in_days
FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY Avg_actual_difference_in_days DESC) AS numbering FROM
CTE)
WHERE numbering <=5;




-- VI. Analysis based on the payments:

-- 1. Find the month on month no. of orders placed using different payment types.
-- Code :

SELECT * FROM
(SELECT FORMAT_DATETIME("%B",o.order_purchase_timestamp) AS Month, p.payment_type,
COUNT(o.order_id) AS orders_count
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.payments` p
ON o.order_id = p.order_id
GROUP BY FORMAT_DATETIME("%B",o.order_purchase_timestamp),p.payment_type
)
ORDER BY orders_count DESC;


-- OR

-- Code:
SELECT * FROM
(SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS Year,
FORMAT_DATETIME("%B",o.order_purchase_timestamp) AS Month, p.payment_type,
COUNT(o.order_id) AS orders_count
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.payments` p
ON o.order_id = p.order_id
GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp),
FORMAT_DATETIME("%B",o.order_purchase_timestamp),p.payment_type
)
ORDER BY Year, orders_count DESC;



-- 2. Find the no. of orders placed on the basis of the payment installments that have been paid.
-- Code :

SELECT payment_installments, COUNT(o.order_id) as orders_count
FROM `Target_Company_Data.orders` o
INNER JOIN `Target_Company_Data.payments` p
ON o.order_id = p.order_id
WHERE payment_installments >=1
GROUP BY p.payment_installments
ORDER BY p.payment_installments;







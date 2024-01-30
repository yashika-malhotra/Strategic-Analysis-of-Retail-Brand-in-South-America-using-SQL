# Strategic Analysis of Target's Operations in Brazil using SQL <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Activities/Bullseye.png" alt="Bullseye" width = 5% height = 5% />
<div align="center">
  <img src="https://github.com/yashika-malhotra/Strategic-Analysis-of-Target-Operations-in-Brazil-using-SQL/blob/main/Target%20Company%20Picture.jpg?raw=true" width = 60% height = 60%/>
</div>

<br/> 
Target is a globally renowned brand and a prominent retailer in the United States. Target makes itself a preferred shopping destination by offering outstanding value, inspiration, innovation and an exceptional guest experience that no other retailer can deliver.

This particular business case focuses on the operations of Target in Brazil and provides insightful information about 100,000 orders placed between 2016 and 2018. The dataset offers a comprehensive view of various dimensions including the order status, price, payment and freight performance, customer location, product attributes, and customer reviews.

🔎Analyze the dataset in <b><code>Google BigQuery </code></b>

📚 The dataset is available in 8 csv iles:

1. customers.csv 
2. geolocation.csv 
3. order_items.csv 
4. payments.csv 
5. reviews.csv 
6. orders.csv 
7. products.csv 
8. sellers.csv
   
<br/> <hr/>
The column description for these csv files are given below.

The customers.csv contain following features:

Features | Description | 
--- | --- 
customer_id | ID of the consumer who made the purchase | 
customer_unique_id | Unique ID of the consumer | 
customer_zip_code_prefix | Zip Code of consumer’s location | 
customer_city | Name of the City from where order is made | 
customer_state | State Code from where order is made (Eg. são paulo - SP) |

<br/> <hr/>

The sellers.csv contains following features:

Features | Description | 
--- | --- 
seller_id | Unique ID of the seller registered | 
seller_zip_code_prefix | Zip Code of the seller’s location | 
seller_city | Name of the City of the seller | 
seller_state | State Code (Eg. são paulo - SP) | 

<br/> <hr/>

The order_items.csv contains following features:

Features | Description | 
--- | --- 
order_id | A Unique ID of order made by the consumers | 
order_item_id | A Unique ID given to each item ordered in the order | 
product_id | A Unique ID given to each product available on the site | 
seller_id | Unique ID of the seller registered in Target | 
shipping_limit_date | The date before which the ordered product must be shipped | 
price | Actual price of the products ordered | 
freight_value | Price rate at which a product is delivered from one point to another | 

<br/> <hr/>

The geolocations.csv contains following features:

Features | Description | 
--- | --- 
geolocation_zip_code_prefix | First 5 digits of Zip Code | 
geolocation_lat | Latitude | 
geolocation_lng | Longitude | 
geolocation_city | City | 
geolocation_state | State | 

<br/> <hr/>

The payments.csv contains following features:

Features | Description | 
--- | --- 
order_id | A Unique ID of order made by the consumers | 
payment_sequential | Sequences of the payments made in case of EMI | 
payment_type | Mode of payment used (Eg. Credit Card) | 
payment_installments | Number of installments in case of EMI purchase | 
payment_value | Total amount paid for the purchase order | 


<br/> <hr/>

The orders.csv contains following features:

Features | Description | 
--- | --- 
order_id | A Unique ID of order made by the consumers | 
customer_id | ID of the consumer who made the purchase | 
order_purchase_timestamp | Status of the order made i.e. delivered, shipped, etc. | 
order_delivered_carrier_date | Delivery date at which carrier made the delivery | 
order_delivered_customer_date | Date at which customer got the product | 
order_estimated_delivery_date | Estimated delivery date of the products | 


<br/> <hr/>

The reviews.csv contains following features:

Features | Description | 
--- | --- 
review_id | ID of the review given on the product ordered by the order id | 
order_id | A Unique ID of order made by the consumers | 
review_score | Review score given by the customer for each order on a scale of 1-5 | 
review_comment_title | Title of the review | 
review_comment_message | Review comments posted by the consumer for each order | 
review_creation_date | Timestamp of the review when it is created | 
review_answer_timestamp | Timestamp of the review answered | 


<br/> <hr/>

The products.csv contains following features:

Features | Description | 
--- | --- 
product_id | A Unique identifier for the proposed project. | 
product_category_name | Name of the product category | 
product_name_lenght | Length of the string which specifies the name given to the products ordered | 
product_description_lenght | Length of the description written for each product ordered on the site | 
product_photos_qty | Number of photos of each product ordered available on the shopping portal | 
product_weight_g | Weight of the products ordered in grams | 
product_length_cm | Length of the products ordered in centimeters | 
product_height_cm | Height of the products ordered in centimeters | 
product_width_cm | Width of the product ordered in centimeters | 

<hr/>

**Dataset schema:**
<div align="center">
  <img src="https://github.com/yashika-malhotra/Strategic-Analysis-of-Target-Operations-in-Brazil-using-SQL/blob/main/Dataset%20schema.png?raw=true" width = 80% height = 80%/>
</div>


# Performed following Tasks

🔍 Imported the dataset and performed exploratory analysis steps like checking the structure & characteristics of the dataset:
1. Data type of all columns in the "customers" table
2. The time range between which the orders were placed
3. Count the Cities & States of customers who ordered during the given period

🔍 In-depth Exploration:
1. Growing trend in the no. of orders placed over the past years?
2. Monthly seasonality in terms of the no. of orders being placed?
3. During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
      - 0-6 hrs : Dawn
      - 7-12 hrs : Mornings
      - 13-18 hrs : Afternoon
      - 19-23 hrs : Night

🔍 Evolution of E-commerce orders in the Brazil region:
1. Month on month number of orders placed in each state
2. How are the customers distributed across all the states?

🔍 Impact on Economy: 
1. Analyzed the money movement by e-commerce by looking at order prices, freight and others
2. Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only)
   (Used the "payment_value" column in the payments table to get the cost of orders)
3. Calculated the Total & Average value of order price for each state
4. Calculated the Total & Average value of order freight for each state

🔍 Analysis based on sales, freight and delivery time:
1. The no. of days taken to deliver each order from the order’s purchase date as delivery time
2. Also, calculated the difference (in days) between the estimated & actual delivery date of an order
      - (Calculated the delivery time and the difference between the estimated & actual delivery date using the given formula:
        <br/>
            time_to_deliver = order_delivered_customer_date - order_purchase_timestamp
            diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date)

3. Top 5 states with the highest & lowest average freight value
4. Top 5 states with the highest & lowest average delivery time
5. Top 5 states where the order delivery is really fast as compared to the estimated date of delivery
   (Used the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state)

🔍 Analysis based on the payments:
1. Month on month no. of orders placed using different payment types
2. Number of orders placed on the basis of the payment installments that have been paid

<br/> <hr/>

# Description about files in repository <img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/Backhand%20Index%20Pointing%20Down%20Light%20Skin%20Tone.png" alt="Backhand Index Pointing Down Light Skin Tone" width="25" height="25" /> :

**target_dataset.sql** - Google Bigquery containing the code for analysis

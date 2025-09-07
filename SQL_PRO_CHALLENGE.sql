use online_food_del;

-- 1 Get_the top 5_customers based on_total orders placed
SELECT c.customer_name, c.customer_id, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.customer_id
ORDER BY total_orders DESC
LIMIT 5;


-- 2 Show_total_amount_spend by_each customer
SELECT c.customer_name,c.customer_id,SUM(m.price*quantity)AS total_spent
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_details od
ON o.order_id=od.order_id
JOIN menu_item m
ON od.item_id=m.item_id
GROUP BY c.customer_name,c.customer_id
ORDER BY total_spent DESC;

-- 3 which resturant has served the highest number of unique customers
SELECT r.rest_name,r.resturant_id,COUNT(DISTINCT o.customer_id)AS unique_customers
FROM resturant r
JOIN orders o
ON r.resturant_id=o.resturant_id
GROUP BY r.rest_name,r.resturant_id
ORDER BY unique_customers DESC
LIMIT 1;

-- 4 Find top 3 most frequently ordered items.
SELECT m.item_name,COUNT(od.order_id) AS times_item_ordered
FROM menu_item m
JOIN order_details od
ON m.item_id=od.item_id
GROUP BY m.item_name
ORDER BY times_item_ordered DESC
LIMIT 3;

-- 5 Get list of customers who have placed more than 3 orders.
SELECT c.customer_name, c.customer_id, COUNT(o.order_id) AS total_order_placed
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.customer_id
HAVING COUNT(o.order_id) > 3;

-- 6 Find average quantity per order per restaurant.
SELECT r.rest_name,r.resturant_id,
  SUM(od.quantity)/ COUNT(DISTINCT o.order_id) AS avg_quantity_per_order
FROM resturant r
JOIN orders o ON r.resturant_id = o.resturant_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY r.resturant_id, r.rest_name;

-- 7 List customers and the restaurants they’ve ordered from more than once
SELECT c.customer_name,r.rest_name,COUNT(o.order_id) AS times_ordered
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN resturant r
ON o.resturant_id=r.resturant_id
GROUP BY c.customer_name,r.rest_name
HAVING COUNT(o.order_id) >1; 

-- 8 Identify the top 3 revenue-generating restaurants
SELECT r.rest_name,SUM(m.price*od.quantity) AS total_revenue
FROM resturant r
JOIN menu_item m
ON r.resturant_id=m.resturant_id
JOIN order_details od
ON m.item_id=od.item_id
GROUP BY r.rest_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 1 Tag customers based on city (metro_cust- mumbai,delhi,rest-non_metro_cust)
SELECT customer_name,customer_id,city,
CASE 
WHEN city='Mumbai' THEN 'Metro_Customer'
WHEN city='Delhi' THEN 'Metro_Customer'
ELSE 'Non_Metro Customer'
END AS city_type
FROM customers;

-- 2 Count order placed by metro vs non metro customers
SELECT
CASE 
WHEN c.city in('Delhi','Mumbai')THEN 'Metro'
ELSE 'Non-Metro' END AS customer_type,COUNT(*) AS total_orders
FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY CASE 
WHEN c.city in('Delhi','Mumbai')THEN 'Metro'
ELSE 'Non-Metro' END ;

-- 3 High vs Low Value Orders (Based on Total Price)
SELECT o.order_id,SUM(m.price*od.quantity) AS total_value,
CASE 
WHEN SUM(m.price*od.quantity)>1000 THEN'High Value'
ELSE 'Low Value'
END AS order_category
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id
JOIN menu_item m
ON od.item_id=m.item_id
GROUP BY o.order_id;

-- 4 Conditional Count – How Many High Value Orders (ABOVE ₹500) & low value orders (BELOW ₹500)
SELECT order_category,COUNT(*) AS total_order_count
FROM (SELECT o.order_id,
SUM(m.price * od.quantity) AS order_total,
CASE
WHEN SUM(m.price * od.quantity) > 500 THEN 'High Value'
ELSE 'Low Value'END AS order_category
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN menu_item m ON od.item_id = m.item_id
GROUP BY o.order_id) AS order_totals
GROUP BY order_category;

-- 5 Categorize Restaurants Based on Year of Registration as an old or new partner (BEFORE 2025 AS OLD PARTNER)
SELECT rest_name,resturant_id,
CASE 
WHEN reg_date < '2025-01-01' THEN 'OLD partner'
ELSE 'NEW partner'
END AS partner_type
FROM resturant;

-- 6 Tag Each Item as "Premium", "Standard",
-- or "Economy" Based on Price ( Price > ₹500 → 'Premium' , ₹201 to ₹500 → 'Standard' , ≤ ₹200 → 'Economy' )
SELECT item_name,
CASE
WHEN price > 500 THEN 'Premium'
WHEN price BETWEEN 201 AND 500 THEN 'Standard'
ELSE 'Economy'
END AS item_type
FROM menu_item;

-- 7 Reward Tier to customers Based on Number of Orders Placed (( >= 10 ) Gold, (BETWEEN 5 AND 9 ) Silver, (<5) Bronze)
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS total_orders,
CASE 
WHEN COUNT(o.order_id) >= 10 THEN 'GOLD'
WHEN COUNT(o.order_id) BETWEEN 5 AND 9 THEN 'SILVER'
ELSE 'BRONZE'
END AS customer_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 8 Classify Customers as "Active", "Moderate", or "Inactive"
-- Based on Signup Year (If signed up in 2025 → 'Active' , in 2024 → 'Moderate , Else → 'Inactive')
SELECT customer_name,customer_id,
CASE
WHEN signup_date > 2025-01-01 THEN 'Active'
WHEN signup_date BETWEEN 2024-12-31 AND 2024-01-01 THEN 'Moderate'
ELSE 'Inactive'
END AS customer_activity_status
FROM customers ;

-- 1 Find customers who placed more orders than the average number of orders per customer
SELECT customer_id,customer_name
FROM customers
WHERE customer_id IN(SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id)>(SELECT AVG(order_count)
FROM (SELECT customer_id,COUNT(order_id)AS order_count
FROM orders 
GROUP BY customer_id) AS customer_orders));

-- 2 Show me the customers who never ordered from a restaurant located in their own city.
SELECT customer_id,customer_name,city
FROM customers c
WHERE NOT EXISTS (
SELECT 1 FROM orders o
JOIN resturant r ON o.resturant_id=r.resturant_id
WHERE o.customer_id=c.customer_id
AND r.city=c.city);

-- 3  For each city, list the restaurant with the highest total revenue.
SELECT r.rest_name,r.city
FROM resturant r
WHERE (r.resturant_id,r.city)IN(SELECT r.resturant_id,r2.city
FROM resturant r2
JOIN orders o ON r2.resturant_id=o.resturant_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY r2.city,r2.resturant_id
HAVING SUM(m.price*od.quantity)=(SELECT MAX(total_revenue)
FROM (SELECT r3.city AS city_name,r3.resturant_id,SUM(m.price*od.quantity) AS total_revenue
FROM resturant r3
JOIN orders o ON r3.resturant_id=o.resturant_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY r3.city,r3.resturant_id) AS city_revenue
WHERE city_revenue.city_name=r2.city));

-- 4 Top 5 Most Expensive Menu Items
SELECT item_name, price
FROM menu_item m1
WHERE (
SELECT COUNT(DISTINCT price)
FROM menu_item m2
WHERE m2.price > m1.price) < 5
ORDER BY price DESC;



-- 5 Find the restaurant with the highest average item price
SELECT r.rest_name, (SELECT AVG(m.price)
FROM menu_item m
WHERE m.resturant_id = r.resturant_id) AS avg_price
FROM resturant r
ORDER BY avg_price DESC
LIMIT 1;

-- 6 Find all restaurants that have received more orders than the average number of orders per restaurant.
SELECT r.rest_name, r.resturant_id, COUNT(o.order_id) AS total_order
FROM resturant r
JOIN orders o ON r.resturant_id = o.resturant_id
GROUP BY r.rest_name, r.resturant_id
HAVING COUNT(o.order_id) > (SELECT COUNT(1) * 1.0 / COUNT(DISTINCT resturant_id)
FROM orders)
ORDER BY total_order DESC;


-- 7 List the most frequently ordered menu item (overall), and how many times it was ordered.
SELECT m.item_name, m.item_id, COUNT(od.order_id) AS times_ordered
FROM menu_item m
JOIN order_details od ON m.item_id = od.item_id
GROUP BY m.item_name, m.item_id
HAVING COUNT(od.order_id) = (SELECT MAX(item_count) FROM (SELECT COUNT(od2.order_id) AS item_count
FROM order_details od2
GROUP BY od2.item_id) AS counts)
ORDER BY times_ordered DESC;

-- 8 Customers with more than 2 total orders 
SELECT c.customer_name, c.customer_id, total_order
FROM customers c
JOIN (SELECT customer_id, COUNT(o.order_id) AS total_order
FROM orders o
GROUP BY customer_id
HAVING COUNT(order_id) > 2) AS o ON c.customer_id = o.customer_id
ORDER BY total_order DESC;

-- 1 First Order of Each Customer
SELECT *
FROM
(SELECT order_id,customer_id,resturant_id,order_date,row_number()
over(partition by customer_id ORDER BY order_date) AS r_n
FROM orders) AS result
WHERE r_n=1;
 
 -- 2 Top 2 Most Expensive Items in Each Restaurant
 SELECT *
 FROM
 (SELECT resturant_id,item_id,item_name,price,rank()over
 (partition by resturant_id order by price desc) as rnk
 FROM menu_item m) AS sub
 WHERE rnk<=2;
 
 -- 3 Find Frequent Diners using NTILE
SELECT customer_id,COUNT(order_id) as total_orders,NTILE(4) over
(order by COUNT(order_id) desc) as quartile
FROM orders
GROUP BY customer_id;

-- 4 : Assign a Serial Number to All Orders 
-- (Gives a unique number to every order in order of date.)
SELECT *
FROM (SELECT order_id,order_date,
ROW_NUMBER() OVER (ORDER BY order_date, order_id)AS serial_number
FROM orders
) AS result;

-- 5 Get First Item in the Menu per restaurant 
-- (Find the alphabetically first item per restaurant.)
SELECT *
FROM
(SELECT resturant_id,item_id,item_name,row_number()
over(partition by resturant_id ORDER BY item_id,item_name ASC) AS r_n
FROM menu_item) AS result
WHERE r_n=1;

-- 6 Total Number of Orders Each Customer Placed 
-- ( Show total orders per customer without collapsing rows.)
SELECT order_id,customer_id,
COUNT(*) OVER (PARTITION BY customer_id ) AS total_orders
FROM orders;

-- 7 Restaurant with Highest Price Menu Item ,1 per restaurant 
-- (Find the most expensive item in each restaurant.)
 SELECT *
 FROM
 (SELECT resturant_id,item_id,item_name,price,rank()over
 (partition by resturant_id order by price desc) as rnk
 FROM menu_item m) AS sub
 WHERE rnk=1;
 
 -- 8 Average Price of Items for Each Restaurant 
 -- (Compare item price to restaurant's average price.)
SELECT resturant_id,item_id,item_name,price,
AVG(price) OVER (PARTITION BY resturant_id) AS avg_price_per_restaurant,
price - AVG(price) OVER (PARTITION BY resturant_id) AS price_diff
FROM menu_item;

-- 1 Customer’s Last Order Date
SELECT customer_id,order_id,MAX(order_date)
OVER(partition by customer_id) AS last_order_date
FROM orders;

-- 2 : Identify Repeat Customers (Customers who have more than 1 order.)
SELECT *
FROM(SELECT customer_id,order_id,order_date,COUNT(order_id) 
OVER (partition by customer_id) AS total_orders
FROM orders) AS sub
WHERE total_orders>1;

-- 3 Get Previous and Next Item Ordered by Each Customer
SELECT customer_id,order_id,order_date,LAG(order_id)
OVER(partition by customer_id ORDER BY order_date) AS prev_order_id,
LEAD(order_id)OVER(partition by customer_id ORDER BY order_date) AS nxt_order_id
FROM orders;

-- 4 Previous Order Date for Each Customer (Compare each order’s date to the previous one for that customer.)
SELECT *
FROM(SELECT customer_id,order_id,order_date,
LAG(order_id) OVER (
PARTITION BY customer_id 
ORDER BY order_date) AS prev_order_id,
LAG(order_date) OVER (PARTITION BY customer_id 
ORDER BY order_date) AS prev_order_date
FROM orders) AS sub
ORDER BY customer_id, order_date;

-- 5 : Next Order Date for Each Customer (Look ahead to see when the customer placed their next order.)
SELECT *
FROM(SELECT customer_id,order_id,order_date,
LEAD(order_id) OVER (
PARTITION BY customer_id 
ORDER BY order_date) AS nxt_order_id,
LEAD(order_date) OVER (PARTITION BY customer_id 
ORDER BY order_date) AS nxt_order_date
FROM orders) AS sub
ORDER BY customer_id, order_date;

-- 6 Find the Cheapest Item per Restaurant
SELECT *
FROM (SELECT resturant_id,item_name,price,
ROW_NUMBER() OVER (PARTITION BY resturant_id 
ORDER BY price ASC) AS cheapest_rn
FROM menu_item) AS sub
WHERE cheapest_rn = 1;

-- 7 Percentile Bucket for Customers (Top/Bottom Tiers) - 
-- (Divide customers into 5 groups (like top 20%, bottom 20%, etc.).)
SELECT customer_id,COUNT(order_id) AS total_orders,
NTILE(5) OVER (ORDER BY COUNT(order_id) DESC) AS top_20_percentile,
NTILE(5) OVER (ORDER BY COUNT(order_id) ASC)  AS bottom_20_percentile
FROM orders
GROUP BY customer_id;

-- 8 Rank Restaurants by Total Revenue Without Gaps 
-- (restaurants with the same revenue should have the same rank, without skipping numbers.)
SELECT  resturant_id,rest_name,total_revenue,
DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (SELECT r.resturant_id,r.rest_name,SUM(m.price * od.quantity) AS total_revenue
FROM resturant r
JOIN menu_item m ON r.resturant_id = m.resturant_id
JOIN order_details od ON m.item_id = od.item_id
GROUP BY r.resturant_id, r.rest_name) AS revenue_per_restaurant
ORDER BY revenue_rank, resturant_id;

-- 1 customer_total_spend
CREATE VIEW customer_total_spend AS
SELECT c.customer_id,c.customer_name,SUM(m.price*od.quantity) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY c.customer_id,c.customer_name;

-- filter customer - big spenders >1000/-
SELECT *
FROM customer_total_spend
WHERE total_spend >1000;

-- 2 customer_order_count
CREATE VIEW customer_order_count AS 
SELECT c.customer_id,c.customer_name,COUNT(o.order_id)AS total_orders
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name;

-- frequent buyers >5
SELECT * FROM customer_order_count
WHERE total_orders >5;

-- 3  most_ordered_items
CREATE VIEW most_ordered_items AS
SELECT m.item_id,m.item_name,SUM(od.quantity) AS total_ordered_quantity
FROM menu_item m
JOIN order_details od ON m.item_id=od.item_id
GROUP BY m.item_id,m.item_name
ORDER BY total_ordered_quantity DESC;

-- Top 3 most loved items
SELECT * FROM most_ordered_items
LIMIT 3;

-- 4 Create a SQL view named avg_spend_per_order that displays each order’s ID,
-- the customer ID, and the total spend for that order
CREATE VIEW avg_spend_per_order AS 
SELECT o.order_id,c.customer_id,SUM(m.price*od.quantity) AS order_total
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY o.order_id,c.customer_id;

-- find the average of total orders by per customer
SELECT customer_id,AVG(order_total) AS avg_spend_per_order
FROM avg_spend_per_order
GROUP BY customer_id;


-- 5 Create a SQL view named restaurant_performance that displays each 
-- restaurant’s ID, name, total number of orders, and totalrevenue.
CREATE VIEW restaurant_performance AS
SELECT r.resturant_id,r.rest_name,COUNT(o.order_id),SUM(m.price*od.quantity)AS total_revenue
FROM resturant r
JOIN orders o ON r.resturant_id=o.resturant_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY r.resturant_id,r.rest_name; 

-- Top 5 best performing resturants
SELECT * FROM restaurant_performance
ORDER BY total_revenue DESC
LIMIT 5;

-- 6 Create a SQL view named city_customer_spending that displays each city 
-- and the total amount spent by customers from that city.
CREATE VIEW city_customer_spending AS
SELECT c.customer_id,c.customer_name,c.city,SUM(m.price*od.quantity) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY c.customer_id,c.customer_name,c.city;

-- city_customer_spending In chennai
SELECT * FROM city_customer_spending
WHERE city = 'Chennai';

-- 7 :Create a SQL view named top_high_value_orders that displays the top 5 highest-value orders. 
-- The view should include the order ID, customer name, order date, and the total order value.
CREATE VIEW top_high_value_orders AS
SELECT o.order_id,c.customer_name,o.order_date,SUM(m.price*od.quantity) AS total_order_value
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY o.order_id,c.customer_name,o.order_date;

-- find top 5 high value orders
SELECT * FROM top_high_value_orders
ORDER BY total_order_value DESC
LIMIT 5;

-- 8 Create a SQL view named customers_without_orders that lists all customers who have never placed an order.
-- The view should include the customer ID, name, email, city, and signup date.
CREATE VIEW customers_without_orders AS 
SELECT c.customer_id,c.customer_name,c.email,c.city,c.signup_date
FROM customers c
WHERE customer_id NOT IN (SELECT customer_id FROM orders);

-- show customer without a single orders
SELECT * FROM customers_without_orders

-- 1 Find top 3 customers (based on total spending) using a temporary table
;CREATE TEMPORARY TABLE temp_total_spending AS
SELECT c.customer_id,c.customer_name,SUM(m.price*od.quantity) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY c.customer_id,c.customer_name;

SELECT * FROM temp_total_spending
ORDER BY total_spend
LIMIT 3;

-- 2 Top 3 restaurants by revenue
CREATE TEMPORARY TABLE temp_resturant_revenue AS 
SELECT r.resturant_id,r.rest_name,SUM(m.price*od.quantity) AS total_revenue
FROM resturant r
JOIN orders o ON o.resturant_id=r.resturant_id
JOIN order_details od ON od.order_id=o.order_id
JOIN menu_item m ON m.item_id=od.item_id
GROUP BY r.resturant_id,r.rest_name;

SELECT * FROM temp_resturant_revenue
ORDER BY total_revenue DESC
LIMIT 3;

-- 3 Explorers: customers who ordered from 5+ different restaurants
CREATE TEMPORARY TABLE temp_customer_spend AS
SELECT o.customer_id,COUNT(o.resturant_id) AS distinct_rest
FROM orders o 
GROUP BY o.customer_id;

SELECT c.customer_id,c.customer_name,t.distinct_rest
FROM temp_customer_spend t
JOIN customers c
ON c.customer_id=t.customer_id
WHERE t.distinct_rest >=5
ORDER BY t.distinct_rest DESC,c.customer_name;

-- 4 Customer Order Count
CREATE TEMPORARY TABLE temp_customer_order_count AS 
SELECT c.customer_id,c.customer_name,COUNT(o.order_id)AS total_orders
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name;

-- show customers who have more than 2 orders.
SELECT * FROM temp_customer_order_count
WHERE total_orders > 2
ORDER BY total_orders DESC;

-- 5 Restaurant Revenue
CREATE TEMPORARY TABLE temp_per_resturant_revenue AS 
SELECT r.resturant_id,r.rest_name,SUM(m.price*od.quantity) AS total_revenue
FROM resturant r
JOIN orders o ON o.resturant_id=r.resturant_id
JOIN order_details od ON od.order_id=o.order_id
JOIN menu_item m ON m.item_id=od.item_id
GROUP BY r.resturant_id,r.rest_name;

-- display restaurants where revenue is above ₹20,000.
SELECT * FROM temp_per_resturant_revenue 
WHERE total_revenue > 20000
ORDER BY total_revenue DESC;

-- 6 High Value Orders
CREATE TEMPORARY TABLE temp_high_value_orders AS
SELECT o.order_id,c.customer_name,SUM(m.price*od.quantity) AS total_order_value
FROM customers c 
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY o.order_id,c.customer_name;

-- show only orders above ₹1,000.
SELECT * FROM temp_high_value_orders
WHERE total_order_value >1000
ORDER BY total_order_value DESC;

-- 7 Popular Items
CREATE TEMPORARY TABLE temp_popular_item AS 
SELECT m.item_id,m.item_name,COUNT(od.quantity) AS quantity_sold
FROM menu_item m
JOIN order_details od ON m.item_id=od.item_id
GROUP BY m.item_id,m.item_name;

-- show the top 5 items by quantity
SELECT * FROM temp_popular_item
ORDER BY quantity_sold DESC
LIMIT 5;

-- 8 “Big cart” orders: orders with 5+ items (quantity-wise)
CREATE TEMPORARY TABLE temp_big_cart AS 
SELECT m.item_id,m.item_name,COUNT(od.quantity) AS quantity_sold
FROM menu_item m
JOIN order_details od ON m.item_id=od.item_id
GROUP BY m.item_id,m.item_name
HAVING quantity_sold > 5;

-- Find orders with 5+ items using a temp table of order item counts.
SELECT od.order_id,t.quantity_sold
FROM temp_big_cart t
JOIN order_details od
ON od.item_id=t.item_id
ORDER BY t.quantity_sold DESC;

-- 1 Total orders per customer
WITH orders_per_customer AS 
(SELECT o.customer_id,COUNT(*) AS total_orders
FROM orders o
GROUP BY o.customer_id)

SELECT c.customer_name,opc.total_orders
FROM orders_per_customer opc
JOIN customers c ON c.customer_id=opc.customer_id
ORDER BY total_orders DESC;

-- 2 First order date per customer
WITH first_orders AS 
(SELECT o.customer_id,MIN(o.order_date) AS first_order_date
FROM orders o 
GROUP BY o.customer_id)

SELECT c.customer_name,f.first_order_date
FROM first_orders f
JOIN customers c ON c.customer_id=f.customer_id
ORDER BY f.first_order_date;

-- 3 Number of menu items per restaurant
WITH item_per_rest AS 
(SELECT m.resturant_id,COUNT(*) AS item_count
FROM menu_item m
GROUP BY m.resturant_id)

SELECT r.rest_name,i.item_count
FROM item_per_rest i
JOIN resturant r ON r.resturant_id=i.resturant_id
ORDER BY i.item_count DESC;

-- 4 Top 5 most sold items (by quantity)
WITH item_qty AS 
(SELECT od.item_id,COUNT(od.quantity) AS total_qty
FROM order_details od
GROUP BY od.item_id)

SELECT m.item_name,i.total_qty
FROM item_qty i
JOIN menu_item m ON m.item_id=i.item_id
ORDER BY i.total_qty DESC;

-- 5 Customers who never ordered
WITH active_customers AS 
(SELECT DISTINCT o.customer_id
FROM orders o)

SELECT c.customer_id,c.customer_name
FROM customers c
LEFT JOIN active_customers ac ON c.customer_id = ac.customer_id
WHERE ac.customer_id IS NULL;  

-- 6  Active customer list (placed at least one order) 
WITH active_customers AS 
(SELECT DISTINCT o.customer_id
FROM orders o)

SELECT c.customer_id, c.customer_name
FROM customers c
JOIN active_customers ac 
ON c.customer_id = ac.customer_id;

-- 7 Items sold per day (quantity)
WITH day_items AS
(SELECT o.order_date AS d,SUM(od.quantity) AS items_sold
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date)

SELECT *
FROM day_items
ORDER BY d;

-- 8 Average item price per restaurant
WITH  avg_price AS
(SELECT m.resturant_id, r.rest_name,AVG(m.price) AS average_price
FROM menu_item m
JOIN resturant r ON m.resturant_id=r.resturant_id
GROUP BY m.resturant_id,r.rest_name)

SELECT * 
FROM avg_price
ORDER BY average_price DESC;

-- 1 Customers Who Ordered From More Than 2 Restaurants
WITH cust_rest_count AS
(SELECT customer_id,COUNT(DISTINCT resturant_id) AS rest_count
FROM orders 
GROUP BY customer_id)

SELECT c.customer_name,rest_count
FROM cust_rest_count cr
JOIN customers c ON c.customer_id=cr.customer_id
WHERE rest_count >2;

-- 2 Orders Placed on Weekends
WITH weekend_orders AS 
(SELECT order_id,order_date,dayofweek(order_date) AS day_num
FROM orders)

SELECT order_id,order_date
FROM weekend_orders
WHERE day_num IN (1,7);

-- 3 Cheapest Item in Each Restaurant
WITH min_price AS 
(SELECT m.resturant_id,MIN(m.price) AS min_price
FROM menu_item m
GROUP BY m.resturant_id)

SELECT r.rest_name,m.item_name,min_price
FROM min_price mp
JOIN menu_item m ON m.resturant_id=mp.resturant_id
JOIN resturant r ON r.resturant_id=m.resturant_id;

-- 4 Menu Items That Were Never Ordered
WITH item_never_sold AS 
(SELECT DISTINCT od.item_id
FROM order_details od)

SELECT m.item_id,m.item_name
FROM menu_item m
LEFT JOIN item_never_sold ins ON m.item_id = ins.item_id
WHERE ins.item_id IS NULL;

-- 5 Orders With More Than 3 Items 
WITH order_count AS 
(SELECT od.order_id,SUM(quantity) AS times_ordered
FROM order_details od
GROUP BY od.order_id)

SELECT * FROM order_count oc
WHERE times_ordered >3
ORDER BY times_ordered DESC;

-- 6 One-Time Customers
WITH one_time_cust AS 
(SELECT o.customer_id,COUNT(o.order_id) AS times_ordered
FROM orders o
GROUP BY o.customer_id)

SELECT c.customer_name,c.customer_id,times_ordered
FROM one_time_cust otc
JOIN customers c ON c.customer_id=otc.customer_id
WHERE times_ordered = 1; 

-- 7  Restaurant Revenue Leaderboard
WITH revenue_leaderboard AS 
(SELECT r.resturant_id,r.rest_name,SUM(m.price * od.quantity) AS total_revenue
FROM resturant r 
JOIN menu_item m ON r.resturant_id = m.resturant_id
JOIN order_details od ON m.item_id = od.item_id
GROUP BY r.resturant_id, r.rest_name)

SELECT resturant_id,rest_name,total_revenue,
RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM revenue_leaderboard
ORDER BY revenue_rank;

-- 8 Customers Who Ordered From More Than 3 Restaurants
WITH cust_rest_count AS
(SELECT customer_id,COUNT(DISTINCT resturant_id) AS rest_count
FROM orders 
GROUP BY customer_id)

SELECT c.customer_name,rest_count
FROM cust_rest_count cr
JOIN customers c ON c.customer_id=cr.customer_id
WHERE rest_count >3;

-- 1 Orders for a Specific Customer
DELIMITER //
CREATE PROCEDURE orderbycustomer(IN cust_id int)
BEGIN 
SELECT * FROM orders WHERE customer_id=cust_id;
END//
DELIMITER ;
CALL orderbycustomer(30);

-- 2 Customers in a Specific City
DELIMITER //
CREATE PROCEDURE custbycity (IN city_name VARCHAR(5))
BEGIN
SELECT * FROM customers
WHERE city=city_name;
END//
DELIMITER ;
CALL custbycity('delhi');

-- 3 Best-Selling Menu Items
DELIMITER //
CREATE PROCEDURE bestsellingitems (IN limit_num INT)
BEGIN 
SELECT m.item_name,SUM(od.quantity) AS total_sold
FROM menu_item m
JOIN order_details od ON m.item_id=od.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC
LIMIT limit_num;
END //
DELIMITER ;
CALL bestsellingitems(5);

-- 4 Restaurants in a Specific City
DELIMITER //
CREATE PROCEDURE restbycity (IN city_name VARCHAR(5))
BEGIN
SELECT r.resturant_id,r.rest_name,r.city FROM resturant r
WHERE r.city=city_name;
END//
DELIMITER ;
CALL restbycity('delhi');

-- 5 Revenue Between Two Dates 
DELIMITER //
CREATE PROCEDURE revenuebetweendates (IN start_date DATE,IN end_date DATE)
BEGIN
SELECT SUM(m.price * od.quantity) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN menu_item m ON od.item_id = m.item_id
WHERE o.order_date BETWEEN start_date AND end_date;
END //
DELIMITER ;
CALL revenuebetweendates('2024-01-01', '2024-01-07');

-- 6 Top N Customers by Orders
DELIMITER //
CREATE PROCEDURE topcustomer (IN limit_num INT)
BEGIN 
SELECT c.customer_name,COUNT(o.order_id) AS total_order
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_name
ORDER BY total_order DESC
LIMIT limit_num;
END //
DELIMITER ;
CALL topcustomer (5);

-- 7 Orders for a Specific Restaurant
DELIMITER //
CREATE PROCEDURE orderbyrest (IN rest_id INT)
BEGIN
SELECT order_id,customer_id,resturant_id,o.order_date
FROM orders o 
WHERE resturant_id = rest_id;
END //
DELIMITER ;
CALL orderbyrest (7);

-- 8 First Order Date for Each Customer 
DELIMITER //
CREATE PROCEDURE firstorderbycustomer ()
BEGIN
SELECT customer_id,MIN(order_date)
FROM orders o 
GROUP BY customer_id;
END //
DELIMITER ;
CALL firstorderbycustomer();

-- 1  Customer Signups Category 
-- Task: Classify customers as “Early Bird” (signup before 2024), “Regular” (2024), or “New” (2025).
SELECT customer_name,customer_id,signup_date,
CASE 
WHEN signup_date <'2024-01-01' THEN 'Early Bird'
WHEN signup_date BETWEEN '2024-01-01' AND '2024-12-31' THEN 'Regular'
ELSE 'New'
END AS customer_type
FROM customers;

-- 2 Customers with Max Orders
-- Task: Find customers who placed the maximum number of orders.
CREATE VIEW customer_order_count AS 
SELECT c.customer_id,c.customer_name,COUNT(o.order_id)AS total_orders
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name;

SELECT customer_id,customer_name,total_orders
FROM customer_order_count
ORDER BY total_orders DESC;

-- 3 Menu Items Priced Above Global Average 
-- Task: Show items that are priced higher than the average price of all menu items.
SELECT item_id,item_name,price,(SELECT AVG(price) FROM menu_item) AS global_avg_price
FROM menu_item
WHERE price > (SELECT AVG(price)
FROM menu_item);

-- 4 Restaurants With More Items Than Avg 
-- Task: Show restaurants that offer more menu items than the overall average.
SELECT r.resturant_id,r.rest_name,COUNT(m.item_id) AS item_count
FROM resturant r
JOIN menu_item m ON r.resturant_id = m.resturant_id
GROUP BY r.resturant_id, r.rest_name
HAVING COUNT(m.item_id) > (SELECT AVG(item_count) 
FROM (SELECT COUNT(item_id) AS item_count FROM menu_item
GROUP BY resturant_id ) sub)
ORDER BY item_count DESC;

-- 5 Monthly Order Summary 
-- Task: Build a CTE for monthly orders and then filter only months with >50 orders
WITH monthly_orders AS 
(SELECT MONTH(order_date) AS order_month,COUNT(order_id) AS total_orders
FROM orders GROUP BY MONTH(order_date))

SELECT order_month,total_orders
FROM monthly_orders
WHERE total_orders > 50
ORDER BY order_month;

-- 1 Restaurant Size Category 
-- Task: Based on menu items, mark restaurants as Small (<5 items), Medium (5–10), or Large (>10).
SELECT resturant_id,COUNT(item_id) AS total_menu_items,
CASE 
WHEN COUNT(item_id) < 5 THEN 'Small'
WHEN COUNT(item_id) BETWEEN 5 AND 10 THEN 'Medium'
ELSE 'Large'
END AS resturant_size_type
FROM menu_item
GROUP BY resturant_id;

-- 2 Orders per Customer with Rank 
-- Task: Use a CTE to calculate orders per customer and rank them.
WITH orderspercustomer AS 
(SELECT o.customer_id,c.customer_name,COUNT(o.order_id) AS orders_per_customer
FROM orders o 
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY o.customer_id,c.customer_name)

SELECT customer_id,customer_name,orders_per_customer,
RANK() OVER (ORDER BY orders_per_customer DESC) AS customer_rank
FROM orderspercustomer
ORDER BY customer_rank;

-- 3 Store Top 3 Restaurants 
-- Task: Create a temporary table of top 3 restaurants by revenue.
CREATE TEMPORARY TABLE temp_resturant_revenue AS 
SELECT r.resturant_id,r.rest_name,SUM(m.price*od.quantity) AS total_revenue
FROM resturant r
JOIN orders o ON o.resturant_id=r.resturant_id
JOIN order_details od ON od.order_id=o.order_id
JOIN menu_item m ON m.item_id=od.item_id
GROUP BY r.resturant_id,r.rest_name;

SELECT * FROM temp_resturant_revenue
ORDER BY total_revenue DESC
LIMIT 3;

-- 4 Store Orders Last 7 Days 
-- Task: Create a temp table of orders from the last 7 days.
CREATE TEMPORARY TABLE recent7days_orders AS
SELECT o.order_id,o.customer_id,o.resturant_id,o.order_date
FROM orders o
WHERE o.order_date >= ((SELECT MAX(order_date) FROM orders) - INTERVAL 7 DAY);
SELECT * FROM recent7days_orders;

-- 5 Create View for Customer Spend 
-- Task: Create a view showing total spend per customer.
CREATE VIEW per_customer_total_spend AS
SELECT c.customer_id,c.customer_name,SUM(m.price*od.quantity) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN order_details od ON o.order_id=od.order_id
JOIN menu_item m ON od.item_id=m.item_id
GROUP BY c.customer_id,c.customer_name;
-- CUSTOMER SPEND MORE THAN 10000
SELECT *
FROM per_customer_total_spend
WHERE total_spend >10000;

--#1 Find the orders and phone number for Corrina Sawyer where there is an existing order ID (descending)
SELECT first_name, last_name, sc.customer_id, order_id, phone FROM sales.customers AS sc
INNER JOIN sales.orders AS so
ON sc.customer_id = so.customer_id
WHERE order_id IS NOT NULL AND first_name = 'Corrina' AND last_name = 'Sawyer'
ORDER BY order_id DESC

--#2 Find the number of unique customer ID's from orders within January and May 2016
SELECT COUNT(DISTINCT customer_id) AS uniq_cust_id FROM sales.orders
WHERE order_date BETWEEN '2016-01-01' AND '2016-05-01'

--#3 Find the second highest list price from sold items 
SELECT MAX(list_price) AS second_highest FROM sales.order_items
WHERE list_price NOT IN (SELECT MAX(list_price) FROM sales.order_items)

--#4 Find the customer names and ID's whose first name starts with a Z and resides in California (ascending)
SELECT customer_id, first_name FROM sales.customers 
WHERE first_name LIKE 'Z%' AND state = 'CA'
ORDER BY first_name ASC, customer_id ASC

--#5 How many orders occurred on February 20th 2016
SELECT COUNT(order_id) AS feb_20_orders FROM sales.orders
WHERE order_date IN ('2016-02-20') 

--#6 Fetch the information for orders on the Surly Ogre Frameset-2017 purchased from store 3 where customer ID's are higher than 100 and the orders are currently avaiting shipping (ascending)
SELECT pp.product_id, so.store_id, customer_id, product_name, order_date, shipped_date FROM production.products AS pp
INNER JOIN production.stocks AS ps
ON pp.product_id = ps.product_id
INNER JOIN sales.orders AS so
ON so.store_id = ps.store_id
WHERE shipped_date IS NULL AND ps.store_id = '3' AND customer_id >100 AND product_name LIKE 'Surly Ogre %' 
ORDER BY customer_id ASC 

--#7 Find the first 5 order ID's that have an average discount higher than 15%
SELECT TOP 5 order_id, AVG(discount) AS avg_disc FROM sales.order_items
GROUP BY order_id HAVING AVG(discount) >0.15

--#8 Fetch all information for stores 1-3 and add a column listing the state nickname for each store
SELECT *, "State Nickname" =
	CASE 
	WHEN state = 'CA' THEN 'The Golden State'
	WHEN state = 'TX' THEN 'The Lone Star State'
	WHEN state = 'NY' THEN 'The Empire State'
	ELSE 'NA'
	END
FROM sales.stores
WHERE store_id BETWEEN '1' AND '3'

--#9 Find how many bikes were sold each model year 
SELECT model_year, COUNT(quantity) AS bikes_sold FROM sales.order_items AS soi
INNER JOIN production.products AS pp
ON soi.product_id = pp.product_id
GROUP BY model_year

--#10 Find the revenue for each state 
SELECT state, SUM(quantity * list_price * (1 - discount)) AS state_rev
FROM sales.order_items AS soi
INNER JOIN sales.orders AS so
ON soi.order_id = so.order_id	
INNER JOIN sales.stores AS ss
ON so.store_id = ss.store_id
GROUP BY state

--#11 Create a view for the top 3 customers who have spent the most money all time (descending)
CREATE VIEW Top3CustomerSpending
AS
	SELECT TOP 3 CONCAT (first_name, ' ', last_name) AS cust_full_name,
	SUM(quantity * list_price * (1 - discount)) AS total_spent 
	FROM sales.order_items AS soi
	INNER JOIN sales.orders AS so
	ON soi.order_id = so.order_id	
	INNER JOIN sales.customers AS sc
	ON sc.customer_id = so.customer_id
	GROUP BY CONCAT (first_name, ' ', last_name), soi.order_id
	ORDER BY total_spent DESC

--Query to retreive data from created view 'Top3CustomerSpending'
SELECT * FROM Top3CustomerSpending

--#12 Create a stored procedure for the highest quantity products in stock (descending)
CREATE PROCEDURE HighestQuantityProduct
AS 
	SELECT product_id, MAX(quantity) AS LargestInventory FROM production.stocks	
	GROUP BY product_id
	ORDER BY MAX(quantity) DESC, product_id
GO

--Query to retreive data from stored procedure 'HighestQuantityProduct'
EXECUTE HighestQuantityProduct


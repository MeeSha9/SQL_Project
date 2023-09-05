#Task 1
-- A.	Describe the data in hand in your own words. (Word Limit is 500)

-- The superstoresDB is all about the data of sales of products during 2009 to 2012. 
-- This has all the customer details like customer name, customer id, region he belongs to etc..
-- this data base has all the details about products , its sub categories, the order details, profit, discounts obtained and various other categories
-- the SuperStores data base mainly consists of 5 tables i.e, four dimension tables and one fact table
-- 1. cust_dimen table: it contains all the details of customers like customer name, province, region, customer unique id
-- 2. prod_dimen table: this product table is a dimension table which contains all the product details like product category, product sub category and product id
-- 3. market_fact table: this table is a fact table which keep on updating at regular intervals and contains information about all the unique identification numbers as it is easy to identify the information of anything in the process of product ordering to product delivered like Product ID, Order ID, Customer ID, Shipping ID with sales of products, discount during the that ordering date, order quantity , profit , shipping cost , purchase base margin.
-- 4. shipping_dimen table: this table contains the details about shipping of the products like order id, shipping mode, date of shipping and unique shipping id
-- 5. order_dimen table: this table contains details about all the orders done by customers. it has fields like order id , date of product ordered, and order priority

--  B. Identify and list the Primary Keys and Foreign Keys for this dataset.

--      Primary Keys:
--        orders_dimen table   :- Ord_id;
--        prod_dimen table     :- Prod_id, Product_sub_category;
--        cust_dimen table     :- Cust_id;
--        shipping_dimen table :- Ship_id;
--      Foreign key:
--     	  market_fact table    :- Cust_id referecnce cust_dimen table
--								  Ship_id references shipping_dimen table
--								  Prod_id references prod_dimen table
--								  Order_id references orders_dimen table



#Task 2: Basic Analysis
#A.	Find the total and the average sales (display total_sales and avg_sales)
select sum(sales) as total_sales, avg(sales) as average_sales
from market_fact;


#B.	Display the number of customers in each region in decreasing order of no_of_customers. The result should contain columns Region, no_of_customers
select region as Region, count(cust_id) as no_of_customers
from cust_dimen
group by region
order by no_of_customers desc;


#C.	Find the region having maximum customers (display the region name and max(no_of_customers)
select region as Region, count(cust_id) as no_of_customers
from cust_dimen
group by region
order by no_of_customers desc
limit 1;


#D.	Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold)
select Prod_id, sum(Order_Quantity) as no_of_prod_sold
from market_fact
group by prod_id
order by no_of_prod_sold desc;


#E.	Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased (display the customer name, no_of_tables purchased)
select  Customer_Name ,  c.Cust_id, Order_Quantity
 from cust_dimen c 
 join market_fact m on c.Cust_id = m.Cust_id
 where region = 'atlantic' and m.Prod_id = ( select Prod_id
 from prod_dimen
 where Product_Sub_Category = 'tables');


 
#Task 3: Advanced Analysis
#A.	Display the product categories in descending order of profits (display the product category wise profits i.e. product_category, profits)?

select product_category, prod_id ,sum(profit) as profit
from market_fact 
join prod_dimen on market_fact.Prod_id = prod_dimen.Prod_id
group by market_fact.Prod_id 
order by profit ;

#B.	Display the product category, product sub-category and the profit within each sub- category in three columns.

select product_category, product_sub_category, sum(profit)
from prod_dimen 
join market_fact on prod_dimen.Prod_id = market_fact.Prod_id
group by market_fact.Prod_id;

# C.Where is the least profitable product subcategory shipped the most? 
SELECT 
    cust_dimen.region,
    COUNT(shipping_dimen.ship_id) AS no_of_shipments,
    SUM(market_fact.profit) AS profit_in_each_region
FROM
    market_fact
        JOIN
    cust_dimen ON market_fact.cust_id = cust_dimen.cust_id
        JOIN
    shipping_dimen ON market_fact.ship_id = shipping_dimen.ship_id
        JOIN
    prod_dimen ON market_fact.prod_id = prod_dimen.prod_id
WHERE
    prod_dimen.product_sub_category IN (SELECT 
            prod_dimen.product_sub_category
        FROM
            market_fact
                JOIN
            prod_dimen ON market_fact.prod_id = prod_dimen.prod_id
        GROUP BY prod_dimen.product_sub_category
        HAVING SUM(market_fact.profit) <= ALL (SELECT 
                SUM(market_fact.profit) AS profit
            FROM
                market_fact
                    JOIN
                prod_dimen ON market_fact.prod_id = prod_dimen.prod_id
            GROUP BY prod_dimen.product_sub_category))
GROUP BY cust_dimen.region
ORDER BY profit_in_each_region DESC;
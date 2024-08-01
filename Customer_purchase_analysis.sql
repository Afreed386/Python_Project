create database customer_purchase_analysis;
-- IMPORT THE CUSTOMER PURCHASE DATA INTO THE DATABASE

USE customer_purchase_analysis;

SET SQL_SAFE_UPDATES=0;
-- The date column is in text format, so altering the data format there.
update customer_purchase_data  set PurchaseDate =  str_to_date(PurchaseDate, '%Y-%m-%d');
alter table customer_purchase_data modify column PurchaseDate DATE;

-- NORMALIZATION OF THE DATA:
-- Create Table Customers using customer_purchase Table
Create Table Customers As
with cte as(
select distinct (CustomerName) as CustomerName 
from customer_purchase)
select row_number() over(order by CustomerName) as CustomerID, Customer_Name from cte;
select * from customers;

-- Create Table Products using customer_purchase Table
Create Table Products As
with cte as(
select distinct(Productname)as ProductName
from customer_purchase)
select row_number() over(order by ProductName)+1000 as ProductID, ProductName
from cte;
select * from products;

-- Create Table Categories using customer_purchase Table
Create Table Categories As
with cte as(
select distinct(ProductCategory)as CategoryName
from customer_purchase)
select row_number() over(order by CategoryName)+5000 as CategoryID, CategoryName 
from cte;
select * from categories;

-- Creat Tabel Transactions using Customer_purchase Table
Create Table Transactions as
Select c.TransactionID, d.CustomerID, e.ProductID,f.CategoryID,c.PurchaseQuantity,c.PurchasePrice,
c.PurchaseDate,c.Country
From customer_purchase c join Customers d on c.CustomerName = d.CustomerName 
Join Products e on c.ProductName = e.ProductName Join Categories f on c.ProductCategory = f.CategoryName;
select *  from transactions;


-- ADDING CONSTRAINTS:
 alter table Customers
add Primary key (CustomerID);

alter table Products
add Primary key (ProductID);

alter table Categories
add Primary key (CategoryID);

Alter table transactions
add primary key (TransactionID);

alter table transactions
add foreign key(CustomerID) references customers(CustomerID);

alter table transactions
add foreign key(ProductID) references Products(ProductID);

Alter table transactions
add foreign key(CategoryID) references Categories(CategoryID);


-- HANDLING MISSING VALUSE:
-- Identify missing values in Categories table
select *
from categories
where CategoryID is null or CategoryName is null; 

-- Identify missing values in Customers table
select * 
from customers
where CustomerID is null or CustomerName is null;

-- Identify missing values in Products table
select * 
from products
where ProductID is null or ProductName is null;

-- Identify missing values in Transactions table
select *
from Transactions
where TransactionID is null or CustomerID is null 
 or ProductID is null or CategoryID is null 
 or PurchaseQuantity is null or PurchasePrice is null
 or PurchaseDate is null or Country is null;


-- DATA ANALYSING:

-- 1.What is the total revenue generated?
Select round(sum(purchaseprice),2) as Total_revenue
from transactions;

-- 2.What is the average purchase value? 
select round(avg(purchaseprice),2) as Average_purchase_price
from transactions;

-- 3.Who are the top 10 customers by total spending? 
select c.customerid,c.customername,t.country,sum(t.purchaseprice)as Total_spent
from customers c
join transactions t
on c.customerid = t.customerid
group by c.customerid,c.customername,t.country
order by Total_spent desc
limit 10;

-- 4.Which are the top 5 products by total sales?
select p.productid,p.productname,round(sum(t.purchaseprice),2)as Total_sales
from products p 
join transactions t 
on p.productid = t.productid
group by 1,2
order by Total_sales desc
limit 5;

-- 5.What is the monthly revenue for the past year?
select date_format(purchasedate, '%y - %m')as month_,round(sum(purchaseprice),2) as Monthly_revenue
from transactions
where purchasedate >= date_sub(curdate(),interval 1 year)
group by date_format(purchasedate, '%y - %m')
order by month_;

-- 6.Calculate the country wise Revenue:
select country,round(sum(purchaseprice),2)as Total_quantity
from transactions
group by country
order by 2 desc;

-- 7.Calculate category wise revenue.
select c.categoryid,categoryname,round(sum(t.purchaseprice),2)as Total_spent
from categories c
join transactions t 
on c.categoryid = t.categoryid
group by 1,2
order by Total_spent;

-- 8.How many unique customers made purchases in the past month?
select count(distinct customerid)as Unique_customers
from transactions
where purchasedate >= date_sub(curdate(), interval 1 month);

-- 9.Calculate Year Wise, month wise sales
select year(purchasedate)as Year_,month(purchasedate)as Month_,round(sum(purchaseprice),2)as Total_sales
from transactions 
group by 1,2
order by 1,2,3;

-- 10.What is the total revenue by customer for the past quarter?
select c.customerid,c.customername,sum(t.purchaseprice)as Total_revenue
from customers c
join transactions t
on c.customerid = t.customerid
where purchasedate >= date_sub(curdate(),interval 3 month)
group by 1,2
order by 3;

-- 11.What are the top 5 days with the highest revenue for that product?
select date(t.purchasedate)as Purchase_date,p.productid,p.productname,round(sum(t.purchaseprice),2)as Daily_revenue
from transactions t
join products p on t.productid = p.productid
group by 1,2,3
order by 4 desc
limit 5;

-- 12.What is the distribution of purchases by product category?
select c.categoryname,count(t.transactionid)as Purchase_count
from categories c
join transactions t
on c.categoryid = t.categoryid
group by 1
order by 2 desc;

-- 13.What are the total number of purchases and total revenue for each quarter of the current year?
select
	quarter(purchasedate)as Quarter_,count(transactionid)as Total_purchase,
	round(sum(purchaseprice),2)as Total_revenue
from transactions
where year(purchasedate) = year(curdate())
group by quarter(purchasedate)
order by Quarter_;


































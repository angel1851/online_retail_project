create database online_retail;
use online_retail;
use retail;
CREATE TABLE retail (
    Invoice_No VARCHAR(20),
    Stock_Code VARCHAR(20),
    Description VARCHAR(500),
    Quantity INT,
    Invoice_Date VARCHAR(30),
    Unit_Price DECIMAL(10,2),
    Customer_ID VARCHAR(20),
    Country VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:/Users/tojix/Downloads/archive (1)/online_retail.csv'
INTO TABLE retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

drop table customers;
create table customers 
select distinct Customer_ID, Country 
from retail
where Customer_ID is not null;

SHOW INDEX FROM sales;


create table productos as 
select distinct
Stock_Code, Description
from retail;

create table sales
select 
invoice_No, Stock_Code, Customer_id, quantity, unit_price, invoice_date
from retail;

ALTER TABLE sales 
ADD COLUMN total_linea DECIMAL(10,2) AS (Quantity * Unit_Price);
 
select*from sales;



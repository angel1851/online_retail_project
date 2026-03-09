use online_retail;

# Top 10 Productos
SELECT
    s.stock_code,
    p.description,
    SUM(quantity) AS total_units
FROM sales s
JOIN productos p
    ON s.stock_code = p.stock_code
group by s.stock_code, p.description
order by total_units desc
limit 10;

# Top Customers
select 
    c.customer_id,
    c.country,
    sum(s.quantity) as total_units
from customers c
join sales s
    on c.customer_id = s.customer_id
where s.customer_id is not null
group by c.customer_id, c.country
order by total_units desc
limit 10;

# Products with low rotation
select	
	p.description,
    sum(s.quantity) as quantity,
    sum(s.total_linea) as total_revenue
from sales s
join productos p
	on s.stock_code = p.stock_code
group by p.description
order by quantity
limit 10;
   
#Top products with better sales   
select	
	p.description,
    sum(s.quantity) as quantity,
    sum(s.total_linea) as total_revenue
from sales s
join productos p
	on s.stock_code = p.stock_code
group by p.description
order by quantity desc
limit 10;

# Patrones interesantes

#1 Low volume products with high revenue
select 
	distinct p.description,
    sum(s.quantity) as units,
    sum(s.total_linea) as revenue
from sales s
join productos p
	on s.stock_code=p.stock_code
group by p.description, s.quantity
having units < 100
order by revenue desc
limit 10;

                                                                         
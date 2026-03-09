use online_retail;

# Total sales
select sum(total_linea) as total
from sales;


# total sales per month with ranking
with sales_month as (
	select	
		year(invoice_date) as year,
        month(invoice_date) as month,
        sum(total_linea) as month_sales,
        COUNT(DISTINCT customer_id) as new_customers
	from sales
    group by year(invoice_date), month(invoice_date)
)

select
	year,
    month,
    month_sales,
    new_customers,
    rank() over(order by month_sales desc) as ranking 
from sales_month
group by year, month, month_sales;

#Ticket promedio
select
	sum(total_linea)/
	count(distinct invoice_no) as ticket_promedio
from  sales;

#Ticket promedio por pais
select
	c.country,
	sum(s.total_linea)/
	count(distinct s.invoice_no) as ticket_promedio
from  sales s
join customers c
on s.customer_id=c.customer_id
group by c.country;

select sum(total_linea) as total_revenue
from sales;

#Crecimiento mensual y Variacion mes contra mes
with monthly as(
		select
			year(invoice_date) as year,
            month(invoice_date) as month,
            sum(total_linea) as total_sales
            from sales
            group by year, month
),  
sales_lag as(
	select
		year,
        month,
        total_sales,
        lag(total_sales) over (order by year, month) as previous_month
        from monthly
)
select
	year,
    month,
    total_sales,
    round((total_sales-previous_month)/previous_month * 100, 2) as pct_grwth,
    round(total_sales - previous_month, 2) as month_variation
from sales_lag
order by year, month;



  




 
    
    
use online_retail;

# Ranking customers
select
	distinct customer_id, 
    sum(total_linea) as revenue,
    rank() over(order by sum(total_linea) desc) as ranking
from sales
where customer_id is not null
	and trim(customer_id) <> ''
group by customer_id
limit 10;

# Most valuable customers
with customer_revenue as(
	select	
		customer_id,
		sum(total_linea) as revenue
	from sales
	where trim(customer_id) <> ''
	group by customer_id
),

pareto as(
	select
		ROW_NUMBER() OVER (ORDER BY revenue DESC) AS c_rank,
		customer_id,
        revenue,
        sum(revenue) over(order by revenue desc) as cumulative,
        sum(revenue) over(order by revenue desc) /
        sum(revenue) over() as cumulative_percentage
	from customer_revenue
)

select *
from pareto 
where cumulative_percentage <= .8;
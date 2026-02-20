-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

Restaurant Sales & Menu Performance Analysis
Author: Ninad Jumde
Tool used: Bigquery (SQL)

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

#SECTION 1 — Data Exploration
1#Total number of orders recorded.
select
count(distinct(order_id)) as total_orders
from restaurant_orders.clean_order_details

2#Number of unique menu items.
select
count(distinct(item_name)) as total_menu_items
from restaurant_orders.menu_items

3#Different menu categories available.
select
distinct(category) as category
from restaurant_orders.menu_items

4#Date range of orders.
select
min(order_date) as first_order_date,
max(order_date) as last_order_date
from restaurant_orders.order_details

###
create table restaurant_orders.clean_order_details as
select
order_details_id,
order_id,
order_date,
order_time,
safe_cast(item_id as int64) as item_id
from restaurant_orders.order_details 
where safe_cast(item_id as int64) is not null
###

5#Number of orders placed each day.
select
cod.order_date,
count(*) as number_of_orders
from restaurant_orders.menu_items as m left join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by cod.order_date

6#Order having the highest number of items.
select
order_id,
count(distinct(item_id)) as number_of_items
from restaurant_orders.clean_order_details
group by order_id
order by number_of_items desc

7#Average number of items per order.
select
round(avg(item_count),2) as avg_items_per_order
from
(select
order_id,
count(*) as item_count
from restaurant_orders.clean_order_details
group by order_id)

-----------------------------------------------------------------------------------------------------------------------------

#SECTION 2 — Sales & Revenue Analysis
8#Menu items generating highest total revenue.
select
m.item_name,
m.category,
round(sum(m.price),2) as total_price_of_item
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name, m.category
order by total_price_of_item desc

9#Top 10 best-selling menu items by quantity.
select
m.item_name,
m.category,
count(m.item_name) as quantity_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name, m.category
order by quantity_ordered desc
limit 10

10#Menu category generating the highest revenue.
select
m.category,
round(sum(m.price),2) total_revenue
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.category
order by total_revenue desc

11#Menu category having the highest number of orders.
select
m.category,
count(*) as num_of_orders
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.category
order by num_of_orders desc

12#Average order value.
select
round(avg(total_order_price),2) as avg_order_value
from
(select
cod.order_id,
sum(m.price) as total_order_price
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by cod.order_id)

13#Total revenue generated over time.
select
cod.order_date,
round(sum(price)) as total_revenue
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by cod.order_date

14#Days having the highest sales volume.
select
format_date('%A',cod.order_date) as day_name,
count(*) as sales_volume
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by day_name
order by sales_volume desc

15#Weekly sales trends.
select
date_trunc(cod.order_date, week) as week_start,
round(sum(m.price)) as total_sales
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by week_start
order by week_start

-----------------------------------------------------------------------------------------------------------------------------

# SECTION 3 — Menu Performance Analysis
16#Menu items that are rarely ordered.
select
m.item_name,
count(*) as times_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name
order by times_ordered asc

17#Menu items that have high price but low demand.
select
m.item_name,
m.price,
count(*) as times_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name, m.price
order by m.price desc, times_ordered asc

18#Items that generate high revenue despite low order quantity.
select
m.item_name,
m.price,
round(sum(price)) as total_revenue,
count(*) as quantity_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name, m.price
order by total_revenue desc, quantity_ordered asc

19#Average price of items within each category.
select
category,
round(avg(price),2) as avg_price_of_item
from restaurant_orders.menu_items
group by category

20#Category having the widest price range.
select
category,
count(*) as number_of_items,
max(price) as max_price,
min(price) as min_price,
round((max(price) - min(price)),2) as price_range
from restaurant_orders.menu_items
group by category
order by price_range desc

21#Potential menu items that could be removed or promoted.
select
m.category,
m.item_name,
m.price,
count(*) as times_ordered,
round(sum(m.price),2) as total_revenue
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.category, m.item_name, m.price
order by m.category asc, total_revenue asc, times_ordered asc

-----------------------------------------------------------------------------------------------------------------------------

#SECTION 4 — Customer Ordering Behavior
22#Distribution of small vs large orders.
select
order_size,
count(*) as number_of_orders
from
(select
cod.order_id,
count(*) as number_of_items,
case
when count(*) <= 2 then 'Small Order (<=2 items)'
when count(*) between 3 and 5 then 'Medium Order (3-5 items)'
else 'Large order (>5 items)'
end as order_size
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by cod.order_id)
group by order_size
order by number_of_orders desc

23#The average number of items per order.
select
round(avg(item_count),2) as avg_items_per_order
from
(select
order_id,
count(*) as item_count
from restaurant_orders.clean_order_details
group by order_id)

-----------------------------------------------------------------------------------------------------------------------------

#SECTION 5 — Time-Based Ordering Patterns
24#Peak ordering hours.
select
extract(hour from parse_time('%I:%M:%S %p', order_time)) as order_hour,
count(*) as num_of_orders
from restaurant_orders.clean_order_details
group by order_hour
order by num_of_orders desc

select
extract(hour from parse_time('%I:%M:%S %p', order_time)) as order_hour,
count(distinct(order_id)) as num_of_orders
from restaurant_orders.clean_order_details
group by order_hour
order by order_hour asc

25#Days of the week having the highest order volume.
select
format_date('%A', cod.order_date) as day_name,
count(distinct(cod.order_id)) as order_volume
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod 
on m.menu_item_id = cod.item_id
group by day_name
order by order_volume desc

26#How does revenue vary by time of day?
select
case
when order_hour between 6 and 11 then 'Morning (6-11)'
when order_hour between 12 and 17 then 'Afternoon (12-17)'
when order_hour between 18 and 21 then 'Evening (18-21)'
else 'Night (22-24)'
end as time_of_day,
round(sum(price)) as total_revenue
from
(select
extract(hour from parse_time('%I:%M:%S %p', order_time)) as order_hour,
m.price
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod 
on m.menu_item_id = cod.item_id)
group by time_of_day
order by total_revenue desc

27#Menu categories that are most popular during different times of day.
select
case
when order_hour between 6 and 11 then 'Morning (6-11)'
when order_hour between 12 and 17 then 'Afternoon (12-17)'
when order_hour between 18 and 21 then 'Evening (18-21)'
else 'Night (22-24)'
end as time_of_day,
category,
count(*) as times_ordered
from
(select
extract(hour from parse_time('%I:%M:%S %p', order_time)) as order_hour,
m.category
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod 
on m.menu_item_id = cod.item_id)
group by time_of_day, category
order by time_of_day desc, times_ordered desc

28#Are weekend orders significantly different from weekday orders?
select
day_type,
count(distinct(order_id)) as num_of_orders
from
(select
order_id,
case
when extract(dayofweek from order_date) in (1,7) then 'Weekend'
else 'Weekday'
end as day_type
from restaurant_orders.clean_order_details)
group by day_type

-----------------------------------------------------------------------------------------------------------------------------

#SECTION 6 — Profitability & Pricing Insights
29#Do higher-priced items contribute significantly to revenue? And what is the relationship between item price and demand?
select
case
when price between 1 and 9 then 'Low Price (1$-9$)'
when price between 10 and 14 then 'Medium Price (10$-14$)'
when price > 14 then 'High Price (>14$)'
end as price_bracket,
count(distinct(m.menu_item_id)) as num_of_menu_items,
count(*) as items_sold,
round(sum(m.price),2) as revenue
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by price_bracket
order by revenue desc

30#Items that may benefit from price adjustment.
select
m.item_name,
m.price,
count(*) as times_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.item_name, m.price
order by m.price asc, times_ordered desc

-----------------------------------------------------------------------------------------------------------------------------

#SECTION 7 — Operational Insights
31#Time periods with lowest kitchen workload.
select
case
when order_hour between 6 and 11 then 'Morning (6-11)'
when order_hour between 12 and 17 then 'Afternoon (12-17)'
when order_hour between 18 and 21 then 'Evening (18-21)'
else 'Night (22-24)'
end as time_of_day,
count(*) as num_of_orders
from
(select
extract(hour from parse_time('%I:%M:%S %p', order_time)) as order_hour,
order_id
from restaurant_orders.clean_order_details)
group by time_of_day
order by num_of_orders

34#Items that require highest preparation frequency.
select
menu_item_id,
item_name,
times_ordered,
dense_rank() over(order by times_ordered desc) as rank
from
(select
m.menu_item_id,
m.item_name,
count(*) as times_ordered
from restaurant_orders.menu_items as m inner join restaurant_orders.clean_order_details as cod
on m.menu_item_id = cod.item_id
group by m.menu_item_id, m.item_name)


-- 1) What are the monthly and quarterly sales trends for Macbooks sold in North America across all years?

-- 1.1) Quarterly Sales Trends 

select
    extract(quarter from o.purchase_ts) as purchase_qtr
  , count(distinct o.id) as order_count
  , round(sum(o.usd_price), 2) as total_sales
  , round(avg(o.usd_price), 2) as aov
from
          `tradeease.orders` as o
  
left join `tradeease.customers` as c
        on o.customer_id = c.id
  
left join `tradeease.geo_lookup` as gl
        on c.country_code = gl.country

where
  lower(o.product_name) like '%macbook%'
    and gl.region = 'NA' -- North America
group by
1
order by
1 desc, 3
;

-- 1.2) Monthly Sales Trends 

select
    extract(month from o.purchase_ts) as purchase_month
  , count(distinct o.id) as order_count
  , round(sum(o.usd_price), 2) as total_sales
  , round(avg(o.usd_price), 2) as aov
from
          `tradeease.orders` as o
  
left join `tradeease.customers` as c
        on o.customer_id = c.id
  
left join `tradeease.geo_lookup` as gl
        on c.country_code = gl.country

where
  lower(o.product_name) like '%macbook%'
    and gl.region = 'NA'
group by
1
order by
1 desc , 3
;

-- 2) What was the monthly refund rate for purchases made in 2020? How many refunds did we have each month in 2021 for Apple products? 

-- 2.1) Monthly Refund Rate 2020

with refund_rate as (
  select
    date_trunc(o.purchase_ts, month) as month
  , round((sum(case when os.refund_ts is not null then 1 else 0 end) / count(distinct o.id)) * 100, 2) as refund_rate
from
          `tradeease.orders` as o
  
left join `tradeease.order_status` as os
       on o.id = os.order_id

where 
  extract(year from o.purchase_ts) = 2020
group by
1
)

select
    round(avg(refund_rate.refund_rate), 2) as avg_refund_rate
from
    refund_rate
;

-- 2.2) Monthly Apple Product Refunds in 2021

select
    date_trunc(o.purchase_ts, month) as month
  , sum(case when os.refund_ts is not null then 1 else 0 end) as refunds
from
          `tradeease.orders` as o
  
left join `tradeease.order_status` as os
       on o.id = os.order_id

where 
  extract(year from o.purchase_ts) = 2021
     
     and ( lower(o.product_name) like '%apple%'
      or   lower(o.product_name) like '%macbook%'
         )
group by
1
order by
1
;

-- 3) Are there certain products that are getting refunded more frequently than others? What are the top 3 most frequently refunded products across all years? What are the top 3 products that have the highest count of refunds?

-- 3.1) Product Refund Frequency (Top 3)

select
    case when o.product_name = '27in"" 4k gaming monitor' then '27in 4K gaming monitor' else o.product_name end as cleaned_product_name
  , round((sum(case when os.refund_ts is not null then 1 else 0 end) / count(distinct o.id)) * 100, 1) as refund_rate
from
          `tradeease.orders` as o
  
left join `tradeease.order_status` as os
       on o.id = os.order_id

group by
1
order by
2 desc
limit
3
;

-- 3.2) Most Refunded Products

select
    case when o.product_name = '27in"" 4k gaming monitor' then '27in 4K gaming monitor' else o.product_name end as cleaned_product_name
  , sum(case when os.refund_ts is not null then 1 else 0 end) as refunds
from
          `tradeease.orders` as o
  
left join `tradeease.order_status` as os
       on o.id = os.order_id

group by
1
order by
2 desc
;

-- 4) What’s the average order value across different account creation methods in the first two months of 2022? Which method had the most new customers in this time?

select
    c.account_creation_method 
  , count(distinct c.id) as num_customers  
  , sum(o.usd_price) / count(distinct o.id) as aov
from
          `tradeease.orders` as o

left join `tradeease.customers` as c
       on o.customer_id = c.id

where
    extract(year from c.created_on) = 2022
     and ( extract(month from c.created_on) = 1
        or extract(month from c.created_on) = 2
         )
group by
1
order by
2 desc
;

-- 5) What is the average time between customer registration and placing an order?

select
    round(avg(date_diff(o.purchase_ts, c.created_on, day)), 1) as days_to_order
from
          `tradeease.orders` as o
  
left join `tradeease.customers` as c
       on o.customer_id = c.id
;

-- 6) Which marketing channels perform the best in each region? Does the top channel differ across regions?

with regional_performance as (
  select
    gl.region
  , c.marketing_channel
  , count(distinct o.id) as num_orders
  , round(sum(o.usd_price) , 2) as total_sales
  , round((sum(o.usd_price) / count(distinct o.id)), 2) as aov 
from
          `tradeease.orders` as o

left join `tradeease.customers` as c
       on o.customer_id = c.id

left join `tradeease.geo_lookup` as gl
       on c.country_code = gl.country

group by
1, 2
order by
1, 2
)

select
    regional_performance.region
  , regional_performance.marketing_channel
  , regional_performance.num_orders
  , regional_performance.total_sales
  , regional_performance.aov
  , row_number() over (partition by regional_performance.region order by regional_performance.num_orders desc) as rank
from
    regional_performance
where regional_performance.marketing_channel is not null
  and regional_performance.marketing_channel != 'unknown'
  and regional_performance.region is not null
order by
6
;

-- 7) For customers who made more than 4 orders across all years, what was the order ID, product, and purchase date of their most recent order?

select
    o.customer_id
  , o.id
  , o.product_name
  , o.purchase_ts
  , row_number() over (partition by o.customer_id order by o.purchase_ts) as ranking
from
`tradeease.orders` as o
group by
1, 2, 3, 4
qualify row_number() over (partition by o.customer_id order by o.purchase_ts) >= 4
order by
1

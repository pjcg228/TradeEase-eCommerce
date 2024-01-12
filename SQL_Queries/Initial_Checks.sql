-- READ ME: For brevity, these checks have mostly been performed in Microsoft Excel - The queries below represent a snippet of the type of checks carried out on this data, this has been limited to the tradeease.orders table so as to avoid repetition across the other tables.
-- A data cleaning "findings" file is available in the repository with notes on all the issues found within the entire dataset.

-- 1) Visual Inspection

select
    o.customer_id
  , o.id
  , o.purchase_ts
  , o.product_id
  , o.product_name
  , o.currency
  , o.local_price
  , o.usd_price
  , o.purchase_platform
from
    `tradeease.orders` as o
limit 250
;

-- 2) Null Check

select
    sum(case when o.customer_id is null then 1 else 0 end) as nullcount_cust_id 
  , sum(case when o.id is null then 1 else 0 end) as nullcount_order_id
  , sum(case when o.purchase_ts is null then 1 else 0 end) as nullcount_purchase_ts
  , sum(case when o.product_id is null then 1 else 0 end) as nullcount_product_id
  , sum(case when o.product_name is null then 1 else 0 end) as nullcount_product_name
  , sum(case when o.currency is null then 1 else 0 end) as nullcount_currency
  , sum(case when o.local_price is null then 1 else 0 end) as nullcount_local_price
  , sum(case when o.usd_price is null then 1 else 0 end) as nullcount_usd_price
  , sum(case when o.purchase_platform is null then 1 else 0 end) as nullcount_purchase_platform  
from
    `tradeease.orders` as o
;

-- 3) Duplicate Check

select
    o.id
  , count(*)
from
    `tradeease.orders` as o
group by
1
having
count(*) > 1;

-- 4) Price Statistics

select
    o.product_name
  , min(o.usd_price) as product_lowest_usd
  , avg(o.usd_price) as product_avg_usd
  , max(o.usd_price) as product_highest_usd
  , stddev(o.usd_price) as product_std_dev_usd
from
    `tradeease.orders` as o
group by
1
;

-- 5) Purchase Date Range

select
    min(o.purchase_ts) as earliest_date
  , max(o.purchase_ts) as latest_date
from
    `tradeease.orders` as o
;

-- 6) Product Order Counts

select
    o.product_name
  , count(*) product_order_count
from
    `tradeease.orders` as o
group by
1
order by
2 desc
;

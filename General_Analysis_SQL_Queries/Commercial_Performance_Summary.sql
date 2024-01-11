-- Section 1: Yearly Sales Summary
-- Purpose: To analyse annual sales performance by calculating total sales, average order value (AOV), total orders, and their respective year-on-year growth percentages. This provides a yearly overview of TradeEase's sales trends.

with yearly_summary as (
  select
      extract(year from o.purchase_ts) as year
    , sum(o.usd_price) as total_sales
    , avg(o.usd_price) as aov
    , count(o.id) as total_orders
  from
    `tradeease.orders` as o
  group by
  1
)

select
    year
  , round(total_sales, 2) as total_sales
  , round(aov, 2) as aov
  , total_orders
  , round((total_sales / lag(total_sales) over (order by year) - 1) * 100, 2) as sales_yearly_growth_pct
  , round((aov / lag(aov) over (order by year) - 1) * 100, 2) as aov_yearly_growth_pct
  , round((total_orders / lag(total_orders) over (order by year) - 1) * 100, 2) as orders_yearly_growth_pct
from
    yearly_summary 
order by
1
;

-- Section 2: Quarterly Sales Summary
-- Purpose: To evaluate sales performance on a quarterly basis. This involves calculating total sales, AOV, total orders, and their quarterly growth percentages, offering insights into seasonal trends and quarterly business performance.

with quarterly_summary as (
  select
    date_trunc(o.purchase_ts, quarter) as quarter,
    extract(year from o.purchase_ts) as year,
    sum(o.usd_price) as total_sales,
    avg(o.usd_price) as aov,
    count(o.id) as total_orders
  from 
      `tradeease.orders` as o
  group by
  1, 2
)

select
    qs.year
  , qs.quarter
  , round(qs.total_sales, 2) as total_sales
  , round(qs.aov, 2) as aov
  , qs.total_orders
  , round((qs.total_sales / lag(qs.total_sales) over (order by qs.quarter) - 1) * 100, 2) as sales_quarterly_growth_pct
  , round((qs.aov / lag(qs.aov) over (order by qs.quarter) - 1) * 100, 2) as aov_quarterly_growth_pct
  , round((qs.total_orders / lag(qs.total_orders) over (order by qs.quarter) - 1) * 100, 2) as orders_quarterly_growth_pct
  , round(sum(qs.total_sales) over (partition by year order by qs.quarter), 2) as cumulative_sales_by_year
from 
    quarterly_summary as qs
order by
1, 2
;


-- Section 3: Monthly Sales Summary
-- Purpose: Aimed at a more detailed analysis of sales, this section calculates total sales, AOV, and total orders on a monthly basis, along with their growth percentages. This helps in understanding monthly sales trends and identifying specific periods of high or low performance.

with monthly_summary as (
  select
      date_trunc(m.purchase_ts, month) as month
    , extract(year from m.purchase_ts) as year
    , sum(m.usd_price) as total_sales
    , avg(m.usd_price) as aov
    , count(m.id) as total_orders
  from `tradeease.orders` as m
  group by
  1, 2
)

select
    ms.month
  , round(ms.total_sales, 2) as total_sales
  , round(ms.aov, 2) as aov
  , ms.total_orders
  , round((ms.total_sales / lag(ms.total_sales) over (order by ms.month) - 1) * 100, 2) as sales_monthly_growth_pct
  , round((ms.aov / lag(ms.aov) over (order by ms.month) - 1) * 100, 2) as aov_monthly_growth_pct
  , round((ms.total_orders / lag(ms.total_orders) over (order by ms.month) - 1) * 100, 2) as orders_monthly_growth_pct
  , round(sum(ms.total_sales) over (partition by year order by ms.month), 2) as cumulative_sales_by_year
from 
    monthly_summary as ms
order by
1
;


-- Section 4: Yearly Regional Sales Summary
-- Purpose: To assess sales performance based on geographical regions. This includes measuring total sales, AOV, total orders, and their yearly growth percentages in each region, providing a regional perspective on sales trends.

with yearly_regional_summary as (
  select
      extract(year from o.purchase_ts) as year
    , gl.region
    , sum(o.usd_price) as total_sales
    , avg(o.usd_price) as aov
    , count(o.id) as total_orders
  from      `tradeease.orders` as o
  
  left join `tradeease.customers` as c
         on o.customer_id = c.id

  left join `tradeease.geo_lookup` as gl
         on c.country_code = gl.country
  
  where gl.region is not null -- scrubs 112 undecipherable records
  group by
  1, 2
),

total_annual_sales as (
  select
      year
    , sum(total_sales) as total_annual_sales
  from 
      yearly_regional_summary
  group by
  1
)

select
    yrs.year
  , yrs.region
  , round(yrs.total_sales, 2) as total_sales
  , round(yrs.aov, 2) as aov
  , yrs.total_orders
  , round((yrs.total_sales / lag(yrs.total_sales) over (partition by yrs.region order by yrs.year) - 1) * 100, 2) as regional_sales_yearly_growth_pct
  , round((yrs.aov / lag(yrs.aov) over (partition by yrs.region order by yrs.year) - 1) * 100, 2) as regional_aov_yearly_growth_pct
  , round((yrs.total_orders / lag(yrs.total_orders) over (partition by yrs.region order by yrs.year) - 1) * 100, 2) as regional_orders_yearly_growth_pct
  , round((yrs.total_sales / tas.total_annual_sales) * 100, 2) as regional_revenue_percentage
from 
      yearly_regional_summary as yrs

join  total_annual_sales as tas
  on  yrs.year = tas.year

order by
1, 2
;


-- Section 5: Rolling 12 Month Summary
-- Purpose: To track sales performance over a rolling 12-month period. This section calculates total sales and their growth percentages, offering a continuous view of TradeEase's performance across a year.

with monthly_sales as (
  select
    date_trunc(ms.purchase_ts, month) as month
  , round(sum(ms.usd_price), 2) as total_sales
  from 
      `tradeease.orders` as ms
  group by
  1
),

rolling_twelve_month_sales as (
  select
    ms.month
  , ms.total_sales
  , sum(ms.total_sales) over (order by ms.month rows between 11 preceding and current row) as rolling_twelve_months
  from monthly_sales as ms
)

select
    rtms.month
  , rtms.total_sales
  , rtms.rolling_twelve_months
  , rtms.rolling_twelve_months - lag(rtms.rolling_twelve_months, 1) over (order by rtms.month) as rolling_twelve_months_diff
  , round(((rtms.rolling_twelve_months - lag(rtms.rolling_twelve_months, 1) over (order by rtms.month)) / lag(rtms.rolling_twelve_months, 1) over (order by rtms.month)) * 100, 2) as rolling_twelve_months_pct_diff
from 
    rolling_twelve_month_sales as rtms
order by
1
;


-- Section 6: Yearly Product Summary
-- Purpose:  To analyse annual sales performance of individual products. This includes calculating total sales, AOV, and total orders for each product, along with their year-on-year growth, providing insights into product popularity and performance.

with yearly_product_summary as (
  select
      extract(year from o.purchase_ts) as year
    , case
          when lower(o.product_name) like '%gaming monitor%' then '27in 4K Gaming Monitor'  -- correcting erroneous records
          when lower(o.product_name) = 'bose soundsport headphones' then 'Bose SoundSport Headphones' -- adjusting case sensitivity for consistency
          when lower(o.product_name) = 'macbook air laptop' then 'Apple Macbook Air Laptop' -- adjusting case sensitivity for consistency and adding brand
          when lower(o.product_name) = 'apple airpods headphones' then 'Apple AirPods Headphones' -- adjusting case sensitivity for consistency and adding brand
          when lower(o.product_name) = 'thinkpad laptop' then 'Lenovo ThinkPad Laptop' -- adjusting case sensitivity for consistency and adding brand
          else o.product_name -- These items (Samsung Charging Cable Pack, Samsung Webcam) are already correctly named and branded
          end as cleaned_product_name
    , sum(o.usd_price) as total_sales
    , avg(o.usd_price) as aov
    , count(o.id) as total_orders
  from
      `tradeease.orders` as o
  group by
  1, 2
),

total_product_sales as (
  select
      year
    , sum(yps.total_sales) as total_annual_sales
    , sum(yps.total_orders) as total_annual_orders 
  from
       yearly_product_summary as yps
  group by
  1
)

select
    yps.year
  , yps.cleaned_product_name
  , round(yps.total_sales, 2) as total_sales
  , round(yps.aov, 2) as aov
  , yps.total_orders
  , round((yps.total_sales / lag(yps.total_sales) over (partition by yps.cleaned_product_name order by yps.year) - 1) * 100, 2) as product_sales_yearly_growth_pct
  , round((yps.aov / lag(yps.aov) over (partition by yps.cleaned_product_name order by yps.year) - 1) * 100, 2) as product_aov_yearly_growth_pct
  , round((yps.total_orders / lag(yps.total_orders) over (partition by yps.cleaned_product_name order by yps.year) - 1) * 100, 2) as product_orders_yearly_growth_pct
  , round((yps.total_sales / tps.total_annual_sales) * 100, 2) as product_revenue_percentage
  , round((yps.total_orders / tps.total_annual_orders) * 100, 2) as product_orders_percentage 
from
      yearly_product_summary as yps

join
      total_product_sales as tps
  on  yps.year = tps.year

order by
  1, 2
;


-- Section 7: Loyalty Programme Performance
-- Purpose: To evaluate the impact of a loyalty programme on sales. This involves analysing total sales, AOV, and total orders in relation to the loyalty programme membership, along with their yearly growth percentages.

with year_loyalty_sales as (
  select
      extract(year from o.purchase_ts) as year
    , coalesce(c.loyalty_program, 0) as loyalty_program_cleaned -- nulls are understood to be non-loyalty members
    , sum(o.usd_price) as total_sales
    , avg(o.usd_price) as aov
    , count(o.id) as total_orders
  from
            `tradeease.orders` as o

  left join `tradeease.customers` as c
         on  o.customer_id = c.id
  
  group by
  1, 2
),

year_total_sales as (
  select
      extract(year from o.purchase_ts) as year
    , sum(o.usd_price) as total_sales_in_year
    , count(o.id) as total_orders_in_year
  from 
      `tradeease.orders` as o
  group by
  1
)

select
    yls.year
  , yls.loyalty_program_cleaned
  , round(yls.total_sales, 2) as total_sales
  , round(yls.aov, 2) as aov
  , yls.total_orders
  , round(yls.total_sales / yts.total_sales_in_year, 2) as revenue_split
  , round(yls.total_orders / yts.total_orders_in_year, 2) as orders_split
  , round((yls.total_sales - lag(yls.total_sales) over (partition by yls.loyalty_program_cleaned order by yls.year)) / lag(yls.total_sales) over (partition by yls.loyalty_program_cleaned order by yls.year) * 100, 2) as annual_revenue_pct_change
  , round((yls.aov - lag(yls.aov) over (partition by yls.loyalty_program_cleaned order by yls.year)) / lag(yls.aov) over (partition by yls.loyalty_program_cleaned order by yls.year) * 100, 2) as annual_aov_pct_change
  , round((yls.total_orders - lag(yls.total_orders) over (partition by yls.loyalty_program_cleaned order by yls.year)) / lag(yls.total_orders) over (partition by yls.loyalty_program_cleaned order by yls.year) * 100, 2) as annual_orders_pct_change
from 
      year_loyalty_sales as yls

join  year_total_sales as yts
  on  yls.year = yts.year

order by
1, 2
;


-- Section 8: Marketing Channel Performance
-- Purpose: To assess the effectiveness of different marketing channels by calculating total sales, average order value (AOV), and total orders for each channel on a yearly basis. This analysis includes measuring the year-on-year growth in these metrics to understand the evolving impact of each marketing channel.

with yearly_marketing_summary as (
  select
      extract(year from o.purchase_ts) as year
    , c.marketing_channel
    , sum(o.usd_price) as total_sales
    , avg(o.usd_price) as aov
    , count(o.id) as total_orders
  from 
            `tradeease.orders` as o
  
  left join `tradeease.customers` as c
         on   o.customer_id = c.id        

  group by
  1, 2
),

total_annual_sales as (
  select
      year
    , sum(total_sales) as total_annual_sales
  from 
      yearly_marketing_summary
  group by
  1
)

select
    yms.year
  , yms.marketing_channel
  , round(yms.total_sales, 2) as total_sales
  , round(yms.aov, 2) as aov
  , yms.total_orders
  , round((yms.total_sales / lag(yms.total_sales) over (partition by yms.marketing_channel order by yms.year) - 1) * 100, 2) as marketing_channel_sales_yearly_growth_pct
  , round((yms.aov / lag(yms.aov) over (partition by yms.marketing_channel order by yms.year) - 1) * 100, 2) as marketing_channel_aov_yearly_growth_pct
  , round((yms.total_orders / lag(yms.total_orders) over (partition by yms.marketing_channel order by yms.year) - 1) * 100, 2) as marketing_channel_orders_yearly_growth_pct
  , round((yms.total_sales / tas.total_annual_sales) * 100, 2) as marketing_channel_revenue_percentage
from 
      yearly_marketing_summary as yms

join  total_annual_sales as tas on
      yms.year = tas.year

order by
1, 2
;


-- Section 10: Regional Delivery and Shipping Performance
-- Purpose: This section aims to evaluate the efficiency of delivery and shipping processes across different regions. It calculates average times from purchase to shipping, shipping to delivery, and total purchase to delivery, along with their yearly changes, providing insight into the logistics performance in each region.

with regional_avg_delivery as (
    select
        gl.region
      , extract(year from os.purchase_ts) as year
      , round(avg(date_diff(os.ship_ts, os.purchase_ts, day)), 2) as avg_purchase_to_ship_days
      , round(avg(date_diff(os.delivery_ts, os.ship_ts, day)), 2) as avg_ship_to_delivery_days
      , round(avg(date_diff(os.delivery_ts, os.purchase_ts, day)), 2) as avg_purchase_to_delivery_days
    from
              `tradeease.orders` as o
    
    left join `tradeease.order_status` as os
        on o.id = os.order_id
    
    left join `tradeease.customers` as c
        on o.customer_id = c.id
    
    left join `tradeease.geo_lookup` as gl
        on c.country_code = gl.country
    
    where 
        gl.region is not null -- scrubs 112 undecipherable records
    group by
    1, 2
)

select
    rad.region
  , rad.year
  , rad.avg_purchase_to_ship_days
  , rad.avg_ship_to_delivery_days
  , rad.avg_purchase_to_delivery_days
  , round((rad.avg_purchase_to_delivery_days - lag(rad.avg_purchase_to_delivery_days) over (partition by rad.region order by rad.year)) / lag(rad.avg_purchase_to_delivery_days) over (partition by rad.region order by rad.year) * 100, 2) as pct_change_purchase_to_delivery
from 
    regional_avg_delivery as rad
order by
1 desc
;


-- Section 11: Regional Product Refunds 
-- Purpose: The focus here is to analyse the refund rates of products within different regions. By assessing the annual refund rates for each product, categorised by region, this query aims to identify trends and potential issues in product satisfaction or quality across different geographical areas.

select
    gl.region
  , extract(year from os.purchase_ts) as year
  , case
        when lower(o.product_name) like '%gaming monitor' then '27in 4k gaming monitor'
        else o.product_name
        end as cleaned_product_name
  , round((sum(case when os.refund_ts is not null then 1 else 0 end) / count(distinct o.id)) * 100, 2) as refund_rate
from
          `tradeease.orders` as o

left join `tradeease.order_status` as os
    on o.id = os.order_id

left join `tradeease.customers` as c
    on o.customer_id = c.id

left join `tradeease.geo_lookup` as gl
    on c.country_code = gl.country

where
     gl.region is not null -- scrubs 112 undecipherable records
group by
1, 2, 3
order by
2, 3

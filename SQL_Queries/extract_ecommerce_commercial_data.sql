with cleaned_orders as (
  select
      o.customer_id
    , o.id as order_id
    , o.purchase_ts as purchase_date
    , o.product_id
    -- clean product names for consistency
    , case
          when lower(o.product_name) like '%gaming monitor%' then '27in 4K Gaming Monitor' 
          when lower(o.product_name) = 'bose soundsport headphones' then 'Bose SoundSport Headphones'
          when lower(o.product_name) = 'macbook air laptop' then 'Apple Macbook Air Laptop'
          when lower(o.product_name) = 'apple airpods headphones' then 'Apple AirPods Headphones'
          when lower(o.product_name) = 'thinkpad laptop' then 'Lenovo ThinkPad Laptop'
          else o.product_name
      end as cleaned_product_name
    -- categorising products based on their brand
    , case
          when lower(o.product_name) like '%apple%' or lower(o.product_name) like '%macbook%' then 'Apple'
          when lower(o.product_name) like '%thinkpad%' then 'Lenovo'
          when lower(o.product_name) like '%samsung%' then 'Samsung'
          when lower(o.product_name) like '%bose%' then 'Bose'
          else 'Unbranded'
      end as product_family        
    , upper(o.currency) as currency
    , o.local_price
    , o.usd_price
    , o.purchase_platform
    , row_number() over (partition by o.customer_id order by o.purchase_ts asc) as customer_numbered_order
  from
      `tradeease.orders` as o
), -- close cte

cleaned_customers as (
  select
      c.id
    , c.marketing_channel
    , c.account_creation_method
    , upper(c.country_code) as country_code
    , c.loyalty_program
    , c.created_on
  from
      `tradeease.customers` as c
), -- close cte

cleaned_geo_lookup as (
  select
      gl.country
    -- clean regions categorise countries 'A1' and 'EU'
    , upper(case
                when gl.country = 'A1' then 'Unknown'
                when gl.country = 'EU' then 'EMEA'
          else gl.region
      end) as cleaned_region
  from
      `tradeease.geo_lookup` as gl
), -- close cte

cleaned_order_status as (
  select
      os.order_id as order_id
    , os.purchase_ts as purchase_date
    , os.ship_ts as ship_date
    , os.delivery_ts as delivery_date
    , os.refund_ts as refund_date
    , case when os.refund_ts is not null then 1 else 0 end as order_refunded
    , date_diff(os.ship_ts, os.purchase_ts, day) as purchase_to_ship_days
    , date_diff(os.delivery_ts, os.purchase_ts, day) purchase_to_delivery_days
    , date_diff(os.delivery_ts, os.ship_ts, day) as ship_to_delivery_days
    , date_diff(os.refund_ts, os.purchase_ts, day) as purchase_to_refund_days
  from 
      `tradeease.order_status` as os
) -- close cte

select
      co.customer_id
    , co.order_id
    , co.purchase_date
    , co.product_id
    , co.cleaned_product_name as product_name
    , co.product_family        
    , co.currency
    , co.local_price
    , co.usd_price
    , co.purchase_platform
    , co.customer_numbered_order
    , cc.marketing_channel
    , cc.account_creation_method
    , cc.loyalty_program
    , cc.created_on
    , cos.ship_date
    , cos.delivery_date
    , cos.refund_date
    , cos.order_refunded
    , cos.purchase_to_ship_days
    , cos.purchase_to_delivery_days
    , cos.ship_to_delivery_days
    , cos.purchase_to_refund_days
    , cgl.country
    , cgl.cleaned_region as region
from
            cleaned_orders as co
  
  left join cleaned_customers as cc
         on co.customer_id = cc.id
  
  left join cleaned_geo_lookup as cgl
         on cc.country_code = cgl.country
  
  left join cleaned_order_status as cos
         on co.order_id = cos.order_id





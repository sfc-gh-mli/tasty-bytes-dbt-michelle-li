{{ config(snowflake_warehouse="tasty_de_wh") }}

select order_ts,
       order_id,
       truck_id,
       truck_brand_name,
       franchise_flag,
       primary_city as city,
       country,
       sum(order_total) as sales_usd,
       sum(cost_of_goods_usd) as cogs_usd,
       sales_usd - cogs_usd as gross_profit_usd,
       round(((((sales_usd - cogs_usd) / sales_usd)) * 100), 2) as sales_margin_pct
  from {{ ref("stg_order_summary") }}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where order_ts >= (select max(order_ts) from {{ this }})

{% endif %}

 group by order_ts,
          order_id,
          truck_id,
          truck_brand_name,
          franchise_flag,
          city,
          country

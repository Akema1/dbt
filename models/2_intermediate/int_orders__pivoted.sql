-- materialized could also be  'view' or 'table' depending on needs
{{
    config(
        materialized='ephemeral'  
    )
}}

with stg_orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

final as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
        user_order_seq
    from stg_orders
    where order_status != 'pending'
)

select * from final
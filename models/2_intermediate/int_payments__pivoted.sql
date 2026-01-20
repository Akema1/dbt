-- or 'view' or 'table' depending on needs
{{
    config(
        materialized='ephemeral'  
    )
}}

with stg_payments as (
    select * from {{ ref('stg_stripe__payments') }}
),

final as (
    select
        order_id,
        payment_amount
    from stg_payments
    where payment_status = 'success'
)

select * from final
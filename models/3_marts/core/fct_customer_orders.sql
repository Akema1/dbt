{{
    config(
        materialized='table',
        tags=['fact']
    )
}}

with int_orders as (
    select * from {{ ref('int_orders__pivoted') }}
),

int_payments as (
    select * from {{ ref('int_payments__pivoted') }}
),

dim_customers as (
    select * from {{ ref('dim_customers') }}
),

order_enriched as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.user_order_seq,
        payments.payment_amount as order_value_dollars,
        payments.payment_amount is not null as is_paid_order
    from int_orders as orders
    left join int_payments as payments
        on orders.order_id = payments.order_id
),

final as (
    select
        -- Order attributes
        orders.order_id,
        orders.order_date,
        orders.order_status,
        orders.order_value_dollars,
        orders.user_order_seq,
        orders.is_paid_order,
        
        -- Customer foreign key
        orders.customer_id,
        
        -- Customer attributes (denormalized for convenience)
        customers.givenname as customer_givenname,
        customers.surname as customer_surname,
        customers.full_name as customer_full_name,
        
        -- Customer metrics (denormalized)
        customers.first_order_date as customer_first_order_date,
        customers.total_order_count as customer_total_order_count,
        customers.customer_lifetime_value,
        customers.non_returned_order_count as customer_non_returned_order_count,
        customers.avg_non_returned_order_value as customer_avg_order_value,
        
        -- Order-specific derived fields
        case
            when orders.order_date = customers.first_order_date
            then true
            else false
        end as is_first_order,
        
        case
            when orders.order_status in ('returned', 'return_pending')
            then true
            else false
        end as is_return
        
    from order_enriched as orders
    inner join dim_customers as customers
        on orders.customer_id = customers.customer_id
)

select * from final
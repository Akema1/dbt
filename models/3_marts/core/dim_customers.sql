{{
    config(
        materialized='table',
        tags=['dimension']
    )
}}

with stg_customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

int_orders as (
    select * from {{ ref('int_orders__pivoted') }}
),

int_payments as (
    select * from {{ ref('int_payments__pivoted') }}
),

customer_order_aggregates as (
    select
        customers.customer_id,
        min(orders.order_date) as first_order_date,
        min(
            case
                when orders.order_status not in ('returned', 'return_pending')
                then orders.order_date
            end
        ) as first_non_returned_order_date,
        max(
            case
                when orders.order_status not in ('returned', 'return_pending')
                then orders.order_date
            end
        ) as most_recent_non_returned_order_date,
        count(distinct orders.order_id) as total_order_count,
        count(
            distinct case
                when orders.order_status not in ('returned', 'return_pending')
                then orders.order_id
            end
        ) as non_returned_order_count,
        coalesce(
            sum(
                case
                    when orders.order_status not in ('returned', 'return_pending')
                    then payments.payment_amount
                    else 0
                end
            ),
            0
        ) as customer_lifetime_value,
        coalesce(
            sum(
                case
                    when orders.order_status not in ('returned', 'return_pending')
                    then payments.payment_amount
                    else 0
                end
            ) / nullif(
                count(
                    distinct case
                        when orders.order_status not in ('returned', 'return_pending')
                        then orders.order_id
                    end
                ),
                0
            ),
            0
        ) as avg_non_returned_order_value
    from stg_customers as customers
    left join int_orders as orders
        on customers.customer_id = orders.customer_id
    left join int_payments as payments
        on orders.order_id = payments.order_id
    group by customers.customer_id
),

final as (
    select
        -- Primary key
        customers.customer_id,
        
        -- Customer attributes
        customers.givenname,
        customers.surname,
        customers.full_name,
        
        -- Order metrics
        coalesce(agg.total_order_count, 0) as total_order_count,
        coalesce(agg.non_returned_order_count, 0) as non_returned_order_count,
        
        -- Date metrics
        agg.first_order_date,
        agg.first_non_returned_order_date,
        agg.most_recent_non_returned_order_date,
        
        -- Financial metrics
        coalesce(agg.customer_lifetime_value, 0) as customer_lifetime_value,
        coalesce(agg.avg_non_returned_order_value, 0) as avg_non_returned_order_value,
        
        -- Derived flags
        case
            when agg.first_order_date is not null then true
            else false
        end as has_ordered,
        
        case
            when agg.total_order_count >= 2 then true
            else false
        end as is_repeat_customer
        
    from stg_customers as customers
    left join customer_order_aggregates as agg
        on customers.customer_id = agg.customer_id
)

select * from final
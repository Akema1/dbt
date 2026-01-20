with source as (
    select * from {{ source('stripe', 'payment') }}
),

transformed as (
    select
        -- Primary key (payment_id would be ideal if it exists)
        
        -- Foreign keys
        orderid as order_id,
        
        -- Dimensions
        status as payment_status,
        case
            when status = 'success' then 'success'
            when status = 'fail' then 'failed'
            else 'pending'
        end as payment_status_category,
        
        -- Metrics
        amount / 100.0 as payment_amount_raw,
        round(amount / 100.0, 2) as payment_amount
        
    from source
)

select * from transformed
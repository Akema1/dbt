with source as (
    select * from {{ source('jaffle_shop', 'orders') }}
),

transformed as (
    select
        -- Primary key
        id as order_id,
        
        -- Foreign keys
        user_id as customer_id,
        
        -- Dimensions
        status as order_status,
        
        -- Dates
        order_date,
        
        -- Metrics
        row_number() over (
            partition by user_id
            order by order_date, id
        ) as user_order_seq
        
    from source
)

select * from transformed
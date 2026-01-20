with source as (
    select * from {{ source('jaffle_shop', 'customers') }}
),

transformed as (
    select
        -- Primary key
        id as customer_id,
        
        -- Dimensions
        first_name as givenname,
        last_name as surname,
        first_name || ' ' || last_name as full_name
        
    from source
)

select * from transformed
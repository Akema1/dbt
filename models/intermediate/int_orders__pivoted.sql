{% set payment_type = ['bank_transfer','credit_card','gift_card','coupon'] %}

with payments as(
    select * 
    from {{ ref('stg_stripe__payment') }}
where status = 'success'
),

final as
(
    select 
        order_id,
        {%- set payment_methods = ['bank_transfer','credit_card','gift_card','coupon'] -%}
        
        {% for payment_method in payment_methods%}
                sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount{%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    from payments
    group by 1
)

select * from final

{% set old_relation = adapter.get_relation(
      database = target.database,
      schema = target.schema,
      identifier = "fct_customer_orders2"
) -%}

{% set dbt_relation = ref('fct_customer_orders') %}

{{ audit_helper.compare_row_counts(
    a_relation = old_relation,
    b_relation = dbt_relation
) }}
{% macro template_example(args) %}

    {% set query %}
        select true as boolean
    {% endset %}

    {% if execute %}
        {% set results = run_query(query).columns[0].values()[0] %}
        {{ log('SQL result ' ~ results, info=true)}}

        select {{ results }} as _is_relation()
        from a_real_table
    {% endif%}

{% endmacro %}
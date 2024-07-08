{% test not_greater_than(model, column_name, field) %}

with validation as (

    select
        {{ column_name }} as base_field
        , {{ field }} as greater_field

    from {{ model }}

),

validation_errors as (

    select
        *
    from validation
    where base_field > greater_field
)

select *
from validation_errors

{% endtest %}
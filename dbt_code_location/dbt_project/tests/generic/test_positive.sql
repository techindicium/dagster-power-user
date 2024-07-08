{% test positive(model, column_name) %}

with validation as (

    select
        {{ column_name }} as positive_field

    from {{ model }}

),

validation_errors as (

    select
        positive_field

    from validation
    -- if this is true, then positive_field is actually not positive!
    where positive_field <= 0

)

select *
from validation_errors

{% endtest %}
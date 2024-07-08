{{
    config(
        unique_key='id_cliente'
    )
}}
with
source_data as (
    select
        cast(customerid as int) as id_cliente,
        cast(personid as int) as id_pessoa,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','sales_customer') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
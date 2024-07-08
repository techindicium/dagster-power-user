{{
    config(
        unique_key='id_produto'
    )
}}
with
source_data as (
    select
        cast(productid as int) as id_produto,
        cast(name as string) as produto,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','production_product') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
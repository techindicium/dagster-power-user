{{
    config(
        unique_key='id_endereco'
    )
}}
with
source_data as (
    select
        cast(addressid as int) as id_endereco,
        cast(city as string) as cidade,
        cast(stateprovinceid as int) as id_estado,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','person_address') }}
)
select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
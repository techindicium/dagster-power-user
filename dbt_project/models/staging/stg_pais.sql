{{
    config(
        unique_key='codigo_pais'
    )
}}
with
source_data as (
    select
        cast(countryregioncode as string) as codigo_pais,
        cast(name as string) as pais,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','person_countryregion') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
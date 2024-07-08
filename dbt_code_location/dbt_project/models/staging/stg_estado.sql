{{
    config(
        unique_key='id_estado'
    )
}}
with
source_data as (
    select
        cast(stateprovinceid as int) as id_estado,
        cast(name as string) as estado,
        cast(countryregioncode as string) as codigo_pais,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','person_stateprovince') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
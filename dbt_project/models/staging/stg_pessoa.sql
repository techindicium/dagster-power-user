{{
    config(
        unique_key='id_entidade_negocio'
    )
}}
with
source_data as (
    select
        cast(businessentityid as int) as id_entidade_negocio,
        cast(_sling_loaded_at as int) as epoca_carregamento,
        concat(
            coalesce(title, ''), ' ',
            coalesce(firstname, ''), ' ',
            coalesce(lastname, ''), ' ',
            coalesce(suffix, '')
        ) as nome_completo
    from {{ source('indicium-sandbox','person_person') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
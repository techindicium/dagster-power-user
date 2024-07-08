{{
    config(
        unique_key='id_motivo_venda'
    )
}}
with
source_data as (
    select
        cast(salesreasonid as int) as id_motivo_venda,
        cast(name as string) as motivo_venda,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','sales_salesreason') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
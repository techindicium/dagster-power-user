{{
    config(
        unique_key=['id_venda', 'id_motivo_venda']
    )
}}
with
source_data as (
    select
        cast(salesorderid as int) as id_venda,
        cast(salesreasonid as int) as id_motivo_venda,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox', 'sales_salesorderheadersalesreason') }}
)

select * from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
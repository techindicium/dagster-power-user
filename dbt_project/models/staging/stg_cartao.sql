{{
    config(
        unique_key='id_cartao'
    )
}}

with
source_data as (
    select
        cast(creditcardid as int) as id_cartao,
        cast(cardtype as string) as tipo_cartao,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','sales_creditcard') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
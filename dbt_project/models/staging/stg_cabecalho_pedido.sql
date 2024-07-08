{{
    config(
        unique_key='id_venda'
    )
}}

with
source_data as (
    select
        cast(salesorderid as int) as id_venda,
        cast(substr(orderdate, 1, 10) as date) as data_venda,
        cast(customerid as int) as id_cliente,
        cast(billtoaddressid as int) as id_endereco_fatura,
        cast(creditcardid as int) as id_cartao,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','sales_salesorderheader') }}
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
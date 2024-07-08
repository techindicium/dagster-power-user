{{
    config(
        unique_key=['id_detalhamento_pedido', 'id_venda']
    )
}}
with
source_data as (
    select
        cast(salesorderdetailid as int) as id_detalhamento_pedido,
        cast(salesorderid as int) as id_venda,
        cast(productid as int) as id_produto,
        cast(orderqty as int) as quantidade_comprada,
        cast(unitprice as float) as preco_unitario,
        cast(unitpricediscount as float) as desconto_percentual_unitario,
        cast(_sling_loaded_at as int) as epoca_carregamento
    from {{ source('indicium-sandbox','sales_salesorderdetail') }} -- noqa: PRS
)

select *
from source_data
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
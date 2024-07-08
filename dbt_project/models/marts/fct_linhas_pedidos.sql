{{
    config(
        unique_key='sk_linha_pedido'
    )
}}

with localidade as (
    select
        sk_localidade,
        id_localidade
    from {{ ref('dim_localidade') }}
),

cliente as (
    select
        sk_cliente,
        id_cliente
    from {{ ref('dim_cliente') }}
),

cartao as (
    select
        sk_cartao,
        id_cartao
    from {{ ref('dim_cartao') }}
),

data as (
    select data_venda
    from {{ ref('dim_data_venda') }}
),

produto as (
    select
        sk_produto,
        id_produto
    from {{ ref('dim_produto') }}
),


detalhes_pedido_com_sk as (
    select
        sdp.id_detalhamento_pedido,
        sdp.id_venda,
        produto.sk_produto as fk_produto,
        sdp.quantidade_comprada,
        sdp.preco_unitario,
        sdp.desconto_percentual_unitario,
        sdp.epoca_carregamento
    from {{ ref('stg_detalhamento_pedido') }} as sdp
    left join produto on sdp.id_produto = produto.id_produto
    {% if is_incremental() %}
        where sdp.epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),


cabecalho_pedido_com_sk as (
    select
        scp.id_venda,
        localidade.sk_localidade as fk_localidade,
        cliente.sk_cliente as fk_cliente,
        cartao.sk_cartao as fk_cartao,
        data.data_venda
    from {{ ref('stg_cabecalho_pedido') }} as scp
    left join localidade on scp.id_endereco_fatura = localidade.id_localidade
    left join cliente on scp.id_cliente = cliente.id_cliente
    left join cartao on scp.id_cartao = cartao.id_cartao
    left join data on scp.data_venda = data.data_venda
),

bridge as (
    select
        id_venda,
        sk_motivo_venda
    from {{ ref('bridge_pedidos_motivo_venda') }}
),

motivo as (
    select sk_motivo_venda
    from {{ ref('dim_motivo_venda') }}
),

final as (
    select
        dps.id_venda,
        dps.id_detalhamento_pedido,
        cps.data_venda,
        dps.fk_produto,
        cps.fk_localidade,
        cps.fk_cliente,
        cps.fk_cartao,
        dps.epoca_carregamento,
        motivo.sk_motivo_venda as fk_motivo_venda,
        dps.quantidade_comprada
        / count(*)
            over (partition by dps.id_detalhamento_pedido, dps.id_venda)
            as quantidade_comprada_alocada_por_motivo,
        dps.preco_unitario
        * dps.quantidade_comprada
        / count(*) over (partition by dps.id_detalhamento_pedido) as vendas_brutas_alocadas_por_motivo,
        dps.preco_unitario
        * dps.quantidade_comprada
        * (1.0 - dps.desconto_percentual_unitario)
        / count(*) over (partition by dps.id_detalhamento_pedido) as vendas_liquidas_alocadas_por_motivo
    from detalhes_pedido_com_sk as dps
    left join cabecalho_pedido_com_sk as cps on dps.id_venda = cps.id_venda
    left join bridge on dps.id_venda = bridge.id_venda
    left join motivo on bridge.sk_motivo_venda = motivo.sk_motivo_venda
)

select
        {{ 
            dbt_utils.generate_surrogate_key(
                ['id_venda', 'id_detalhamento_pedido', 'fk_motivo_venda']
            ) 
        }} as sk_linha_pedido,
        *
from final

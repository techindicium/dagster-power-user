{{
    config(
        unique_key=['id_venda', 'sk_motivo_venda']
    )
}}
with
staging as (
    select
        stg.id_venda,
        dim.sk_motivo_venda,
        stg.epoca_carregamento
    from {{ ref('stg_pedidos_motivo_venda') }} as stg
    left join {{ ref('dim_motivo_venda') }} as dim on stg.id_motivo_venda = dim.id_motivo_venda
)

select * from staging
{% if is_incremental() %}
    where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
{% endif %}
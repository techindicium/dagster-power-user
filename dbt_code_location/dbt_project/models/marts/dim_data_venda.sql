{{
    config(
        unique_key='data_venda'
    )
}}
with
staging as (
    select distinct data_venda
    from {{ ref('stg_cabecalho_pedido') }}
),

transformed as (
    select
        *,
        extract(month from data_venda) as mes,
        extract(year from data_venda) as ano
    from staging
)

select * from transformed
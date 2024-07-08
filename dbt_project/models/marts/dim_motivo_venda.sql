{{
    config(
        unique_key='id_motivo_venda'
    )
}}
with
staging as (
    select
        id_motivo_venda,
        motivo_venda,
        epoca_carregamento
    from {{ ref('stg_motivo_venda') }}
    {% if is_incremental() %}
        where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),

transformed as (
    select
        id_motivo_venda,
        motivo_venda,
        epoca_carregamento,
        row_number() over (order by id_motivo_venda) as sk_motivo_venda -- auto-incremental surrogate key
    from staging
)

select * from transformed
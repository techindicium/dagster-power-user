{{
    config(
        unique_key='id_produto'
    )
}}
with
staging as (
    select
        id_produto,
        produto,
        epoca_carregamento
    from {{ ref('stg_produto') }}
    {% if is_incremental() %}
        where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),

transformed as (
    select
        id_produto,
        produto,
        epoca_carregamento,
        row_number() over (order by id_produto) as sk_produto -- auto-incremental surrogate key
    from staging
)

select * from transformed
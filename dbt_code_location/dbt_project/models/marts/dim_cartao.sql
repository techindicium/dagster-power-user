{{
    config(
        unique_key='id_cartao'
    )
}}
with
staging as (
    select
        id_cartao,
        tipo_cartao,
        epoca_carregamento
    from {{ ref('stg_cartao') }}
    {% if is_incremental() %}
        where epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),

transformed as (
    select
        id_cartao,
        tipo_cartao,
        epoca_carregamento,
        row_number() over (order by id_cartao) as sk_cartao -- auto-incremental surrogate key
    from staging
)

select * from transformed
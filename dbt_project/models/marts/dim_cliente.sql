{{
    config(
        unique_key='id_cliente'
    )
}}
with
staging as (
    select
        stg_cliente.id_cliente,
        stg_pessoa.nome_completo,
        stg_cliente.epoca_carregamento
    from {{ ref('stg_cliente') }}
    left join {{ ref('stg_pessoa') }}
        on stg_cliente.id_pessoa = stg_pessoa.id_entidade_negocio
    {% if is_incremental() %}
        where stg_cliente.epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),

transformed as (
    select
        id_cliente,
        nome_completo,
        epoca_carregamento,
        row_number() over (order by id_cliente) as sk_cliente -- auto-incremental surrogate key
    from staging
)

select * from transformed
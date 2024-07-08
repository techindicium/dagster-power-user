{{
    config(
        unique_key='id_localidade'
    )
}}
with
staging as (
    select
        endereco.id_endereco,
        endereco.cidade,
        estado.estado,
        pais.pais,
        endereco.epoca_carregamento
    from {{ ref('stg_endereco') }} as endereco
    left join {{ ref('stg_estado') }} as estado on endereco.id_estado = estado.id_estado
    left join {{ ref('stg_pais') }} as pais on estado.codigo_pais = pais.codigo_pais
    {% if is_incremental() %}
        where endereco.epoca_carregamento >= (select max(epoca_carregamento) from {{ this }})
    {% endif %}
),

transformed as (
    select
        id_endereco as id_localidade,
        cidade,
        estado,
        pais,
        epoca_carregamento,
        row_number() over (order by id_endereco) as sk_localidade -- auto-incremental surrogate key
    from staging
)

select * from transformed
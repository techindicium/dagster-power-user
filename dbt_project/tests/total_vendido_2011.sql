-- If sum of gross sales in 2011 is not approximately (1%) $12.646.112,16, throws an error */
{{
    config(
        meta={
            'dagster': {
                'ref': {
                    'name': 'fct_linhas_pedidos',
                },
            }
        }
    )
}}

with
vendas_2011 as (
    select sum(vendas_brutas_alocadas_por_motivo) as total
    from {{ ref ('fct_linhas_pedidos') }} f
    join {{  ref('dim_cliente') }} d
    on f.fk_cliente = d.sk_cliente
    where extract(year from data_venda) = 2011
)

select * from vendas_2011 where total not between 0.99 * 12646112.16 and 1.01 * 12646112.16
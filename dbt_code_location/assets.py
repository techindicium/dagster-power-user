from dagster import AssetExecutionContext


from dagster_dbt import (
    DbtCliResource,
    dbt_assets,
)

from .resource import dbt_manifest_path
from .translator import CustomDagsterDbtTranslator


@dbt_assets(
    manifest=dbt_manifest_path,
    exclude="resource_type:seed resource_type:source",
    dagster_dbt_translator=CustomDagsterDbtTranslator(),
)
def aw_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    dbt_build_args = ["build"]
    yield from dbt.cli(dbt_build_args, context=context).stream()

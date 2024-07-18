from copy import deepcopy

from dagster_embedded_elt.sling import (
    SlingResource,
    sling_assets,
)
from dagster_embedded_elt.sling.asset_decorator import METADATA_KEY_REPLICATION_CONFIG
from dagster_embedded_elt.dlt import DagsterDltResource, dlt_assets


from dagster import (
    file_relative_path,
    AssetExecutionContext,
)

from dlt import pipeline
from dlt_config.source import worldbank
from dlt_config.destination import aw_snowflake

from .translators import CustomDagsterSlingTranslator, CustomDagsterDltTranslator
from .partitions import aw_partitions_def, worldbank_partitions_def

replication_path = file_relative_path(__file__, "../sling_config/replication.yaml")


@sling_assets(
    replication_config=replication_path,
    dagster_sling_translator=CustomDagsterSlingTranslator(),
    partitions_def=aw_partitions_def,
)
def aw_assets(context: AssetExecutionContext, sling: SlingResource):
    replication_config = next(iter(context.assets_def.metadata_by_key.values())).get(
        METADATA_KEY_REPLICATION_CONFIG, {}
    )
    timewindow = context.partition_time_window
    start = timewindow.start.to_date_string()
    end = timewindow.end.to_date_string()
    partitioned_replication_config = deepcopy(replication_config)
    partitioned_replication_config.get("defaults", {}).get("source_options", {}).update(
        {"range": f"{start},{end}"}
    )
    yield from sling.replicate(
        context=context,
        replication_config=partitioned_replication_config,
        dagster_sling_translator=CustomDagsterSlingTranslator(),
    )


@dlt_assets(
    dlt_source=worldbank(),
    dlt_pipeline=pipeline(
        pipeline_name="worldbank_ingestion",
        dataset_name="main",
        destination=aw_snowflake,
    ),
    name="worldbank_ingestion",
    group_name="raw_dlt",
    dlt_dagster_translator=CustomDagsterDltTranslator(),
    partitions_def=worldbank_partitions_def,
)
def compute(context: AssetExecutionContext, dlt: DagsterDltResource):
    year = context.partition_key
    yield from dlt.run(context=context, dlt_source=worldbank(year=year))

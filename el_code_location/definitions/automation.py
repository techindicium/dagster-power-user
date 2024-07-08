from dagster import (
    AssetSelection,
    build_schedule_from_partitioned_job,
    define_asset_job,
)

# define a job that will materialize the assets
sling_ingestion_job = define_asset_job(
    "sling_ingestion_job",
    selection=AssetSelection.groups("raw_sling"),
)

dlt_ingestion_job = define_asset_job(
    "dlt_ingestion_job",
    selection=AssetSelection.groups("raw_dlt"),
)
# Addition: a ScheduleDefinition based on the assets partition
sling_ingestion_schedule = build_schedule_from_partitioned_job(job=sling_ingestion_job)

dlt_ingestion_schedule = build_schedule_from_partitioned_job(job=dlt_ingestion_job)

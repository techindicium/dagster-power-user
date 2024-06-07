from dagster import (
    Definitions,
    load_assets_from_modules,
)

from . import assets
from .automation import sling_ingestion_schedule, dlt_ingestion_schedule
from .resources import sling, dlt

all_assets = load_assets_from_modules([assets])


defs = Definitions(
    assets=all_assets,
    schedules=[
        sling_ingestion_schedule,
        dlt_ingestion_schedule,
    ],  # Addition: add the job to Definitions object
    resources={"sling": sling, "dlt": dlt},
)

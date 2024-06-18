from dagster import Definitions

from .assets import aw_dbt_assets
from .resource import dbt


defs = Definitions(
    assets=[aw_dbt_assets],
    resources={
        "dbt": dbt,
    },
)

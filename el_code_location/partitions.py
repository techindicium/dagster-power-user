from dagster import MonthlyPartitionsDefinition, TimeWindowPartitionsDefinition
import os

aw_partitions_def = MonthlyPartitionsDefinition(
    start_date=os.getenv("PARTITIONS_START_DATE"), end_date="2014-06-30"
)

worldbank_partitions_def = TimeWindowPartitionsDefinition(
    start="1970", cron_schedule="0 0 1 1 *", fmt="%Y"
)

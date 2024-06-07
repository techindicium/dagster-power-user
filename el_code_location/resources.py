from dagster_embedded_elt.sling import (
    SlingConnectionResource,
    SlingResource,
)
from dagster_embedded_elt.dlt import DagsterDltResource

from dagster import EnvVar

source = SlingConnectionResource(
    name="AW_S3",
    type="s3",
    bucket=EnvVar("S3_BUCKET"),
    access_key_id=EnvVar("AWS_ACCESS_KEY_ID"),
    secret_access_key=EnvVar("AWS_SECRET_ACCESS_KEY"),
)

target = SlingConnectionResource(
    name="AW_SF",
    type="snowflake",
    host=EnvVar("SF_HOST"),
    database=EnvVar("SF_DATABASE"),
    user=EnvVar("SF_USER"),
    password=EnvVar("SF_PASSWORD"),
    schema=EnvVar("SF_SCHEMA"),
    role=EnvVar("SF_ROLE"),
    warehouse=EnvVar("SF_WAREHOUSE"),
)

sling = SlingResource(
    connections=[
        source,
        target,
    ]
)

dlt = DagsterDltResource()

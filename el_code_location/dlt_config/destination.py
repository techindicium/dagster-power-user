from dlt.destinations import snowflake
import os

snowflake_credentials = {
    "database": os.getenv("SF_DATABASE"),
    "password": os.getenv("SF_PASSWORD"),
    "username": os.getenv("SF_USERNAME"),
    "host": os.getenv("SF_HOST"),
    "warehouse": os.getenv("SF_WAREHOUSE"),
    "role": os.getenv("SF_ROLE"),
}

aw_snowflake = snowflake(credentials=snowflake_credentials)

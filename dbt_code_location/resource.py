import os
from pathlib import Path

from dagster import file_relative_path
from dagster_dbt import DbtCliResource

dbt_project_dir = file_relative_path(__file__, "../dbt_project")

# https://github.com/dagster-io/dagster/issues/9583
dbt = DbtCliResource(
    project_dir=os.fspath(dbt_project_dir),
    dbt_executable=os.getenv("DBT_EXECUTABLE_PATH"),
)

# If DAGSTER_DBT_PARSE_PROJECT_ON_LOAD is set, a manifest will be created at run time.
# Otherwise, we expect a manifest to be present in the project's target directory.
if os.getenv("DAGSTER_DBT_PARSE_PROJECT_ON_LOAD"):
    dbt_manifest_path = (
        dbt.cli(
            ["--quiet", "parse"],
            target_path=Path("target"),
        )
        .wait()
        .target_path.joinpath("manifest.json")
    )
else:
    dbt_manifest_path = dbt_project_dir.joinpath("target", "manifest.json")

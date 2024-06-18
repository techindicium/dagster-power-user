from dagster import AutoMaterializePolicy
from dagster_dbt import DagsterDbtTranslator
from .automation import wait_for_all_parents_policy
from typing import Mapping, Any, Optional


class CustomDbtTranslator(DagsterDbtTranslator):
    @classmethod
    def get_group_name(cls, dbt_resource_props: Mapping[str, Any]) -> Optional[str]:
        """
        Sets dagster asset group as dbt model schema.
        """
        return dbt_resource_props["schema"]

    @classmethod
    def get_auto_materialize_policy(
        cls, dbt_resource_props: Mapping[str, Any]
    ) -> Optional[AutoMaterializePolicy]:
        """
        Sets global auto materialize policy. Can be customized by leveraging dbt_resource_props
        """
        return wait_for_all_parents_policy

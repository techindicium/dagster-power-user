import re
from typing import Mapping, Any, Iterable
from dagster import AssetKey
from dagster_embedded_elt.sling import DagsterSlingTranslator
from dagster_embedded_elt.dlt import DagsterDltTranslator
from dlt.extract.resource import DltResource


class CustomDagsterSlingTranslator(DagsterSlingTranslator):
    @classmethod
    def get_deps_asset_key(
        cls, stream_definition: Mapping[str, Any]
    ) -> Iterable[AssetKey]:
        return None


class CustomDagsterDltTranslator(DagsterDltTranslator):
    def sanitize_name(self, name: str) -> str:
        return re.sub(r"[^a-zA-Z0-9_]", "_", name.replace('"', "").lower())

    def get_deps_asset_keys(self, resource: DltResource) -> Iterable[AssetKey]:
        return []

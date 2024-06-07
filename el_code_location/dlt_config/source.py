import dlt
import requests
from typing import Any, Iterator
from datetime import datetime

ENDPOINT_TEMPLATE = "https://api.worldbank.org/v2/country/ARG;BOL;BRA;CHL;COL;ECU;GUY;PRY;PER;SUR;URY;VEN/indicator/NY.GDP.MKTP.CD?format=json&date={}&page={}&per_page=50"
DEFAULT_YEAR = str(datetime.now().year)


@dlt.source
def worldbank(year: str = DEFAULT_YEAR):
    def get_total_pages_for_year(endpoint_template: str, year: str) -> int:
        """Queries the first page of the target endpoint given by the template to get the total number
        of result pages for a given year."""
        r = requests.get(url=endpoint_template.format(year, 1))
        [page_info, _] = r.json()
        total_pages: int = page_info["pages"]
        return total_pages

    def get_data(endpoint_template: str, year: str) -> Iterator[dict[str, Any]]:
        """Collects data from all pages of the target endpoint given by the template for a given year."""
        total_pages = get_total_pages_for_year(
            endpoint_template=endpoint_template, year=year
        )
        for page in range(1, total_pages + 1):
            r = requests.get(url=endpoint_template.format(year, page))
            [_, page_data] = r.json()
            yield page_data

    yield dlt.resource(
        get_data(endpoint_template=ENDPOINT_TEMPLATE, year=year),
        name="LATAM_GDP_RAW_DATA",
        max_table_nesting=0,
        write_disposition="replace",
    )

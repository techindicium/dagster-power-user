# Dagster Power User

This repo will parallel the Indicium Engineering blog series [Dagster Power User](https://medium.com/indiciumtech/dagster-dbt-a-new-era-in-the-modern-data-stack-971f0c88a9df).

The goal is that, at the end of the series, we have a simple end-to-end data engineering project with
Dagster + embedded-elt + dbt, from deployment to the data marts.

## Setup

- Create and activate a Python virtualenv:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

- Create a `.env` file based on [available example](./.env.example).

- For visualizing the el assets, run:

```bash
dagster dev -m el_code_location
```

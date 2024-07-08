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
dagster dev -m definitions -d el_code_location
```

- For visualizing the dbt assets, run:

```bash
dagster dev -m definitions -d dbt_code_location
```

## Production Deployment Tips

For simplicity, we are developing using a single repo for all assets. A better practice for production
deployments would consist of using 3 repos - at least in similar contexts to this project:

- IaC repo: with the contents of the [infra module](./infra/)
- el repo: with the contents of the [el code location module](./el_code_location/)
- dbt repo: with the contents of the [dbt code location module](./dbt_code_location/)

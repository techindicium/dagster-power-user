ARG PYTHON_IMAGE=python:3.10-slim
FROM $PYTHON_IMAGE

WORKDIR /project

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

RUN cd dbt_project && dbt deps

# allows dagster itself to generate manifest.json
ENV DAGSTER_DBT_PARSE_PROJECT_ON_LOAD 1
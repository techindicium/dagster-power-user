ARG PYTHON_IMAGE=python:3.10-slim
FROM $PYTHON_IMAGE

WORKDIR /project

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

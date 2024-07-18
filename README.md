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

- Before proceeding to the actual deployment, create an S3 bucket (name suggestion: `dagster-ecs-poc-support-bucket`) and upload the
[`sap_adventure_works` folder](./source_data/sap_adventure_works/) to its root.

## Deployment

- Installs: [Terraform, AWS CLI, Docker]
- Create the files `<el|dbt>_code_location/rsa_key.p8` following the [Snowflake Guide to Private Key Auth](https://docs.snowflake.com/en/user-guide/key-pair-auth). **We are not using a passphrase to encrypt the key file for simplicity in this demo, but of course you should do it if you use this auth method in production.**
- Create a `.env` file based on `.env.example`
- Create a `terraform.tfvars` file based on `infra/terraform.tfvars.example`
- Run `chmod -R +x scripts`
- If needed, setup an appropriate bucket and region to store terraform state in the `config.s3.tfbackend` file. Then, do one of the following before apply new terraform plans:
  - Migrate terraform state (recommended): run `./scripts/migrate.sh <stack>`
  - Reset: in case the previous state is no longer available, run `./scripts/reset.sh <stack>`
  For a definition of what a stack means, see the following topic.

*Note: we did not bother about some warnings regarding Terraform variables not being used, as that would not be an issue in a real case scenario using [production deployment best practices](#production-deployment-tips).*

## Usage

We have four stacks under the `infra` directory, `base`, `core`, `dagster`, `locations`. To operate on a given stack, we provide the convenience `scripts`:

- Deployment: `bash scripts/deploy.sh <stack>`
- Retraction: `bash scripts/retract.sh <stack>`

Therefore, we have the following:

### Full Deployment

```bash
bash scripts/deploy.sh base
bash scripts/deploy.sh cluster
bash scripts/deploy.sh locations
bash scripts/deploy.sh dagster
```

OR

```bash
make deploy
```

*Note: if you keep getting a DNS error at the Dagster UI even after successful deployment of all infra modules, restart the core services. For instance, assuming you are using the standard project name (i.e. `dagster-ecs-poc`):*

```bash
aws ecs update-service --force-new-deployment --service dagster-daemon --cluster dagster-ecs-poc-cluster
aws ecs update-service --force-new-deployment --service dagster-webserver --cluster dagster-ecs-poc-cluster
```

OR

```bash
make restart
```

*Then, refresh the page and you should be ready to go!*

### Full Retraction

```bash
bash scripts/retract.sh dagster
bash scripts/retract.sh locations
bash scripts/retract.sh cluster
bash scripts/retract.sh base
```

OR

```bash
make retract
```

## Production Deployment Tips

For simplicity, we are developing using a single repo for all assets. A better practice for production
deployments would consist of using 3 repos - at least in similar contexts to this project:

- IaC repo: with the contents of the [infra module](./infra/)
- el repo: with the contents of the [el code location module](./el_code_location/)
- dbt repo: with the contents of the [dbt code location module](./dbt_code_location/)

## Issues

There have been intermittent issues with the deployment of the "dagster" stack, but re-execution by
running `bash scripts/deploy.sh dagster` has been sufficient to solve.

We recommend using appropriate CI/CD workflows for deploying ECR images and managing ECS Tasks, for instance
[AWS Deploy ECS Task Github Action](https://github.com/aws-actions/amazon-ecs-deploy-task-definition).

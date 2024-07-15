terraform {
  backend "s3" {
    key = "infra/persistence/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.36.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = local.project_name
    }
  }
}

locals {
  project_name  = "dagster-ecs-poc"
  cluster_name  = "${local.project_name}-cluster"
  postgres_auth = tomap(jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string))
  dagster_env = {
    DAGSTER_POSTGRES_USER     = local.postgres_auth["username"],
    DAGSTER_POSTGRES_PASSWORD = local.postgres_auth["password"],
    DAGSTER_POSTGRES_HOSTNAME = module.postgres.db_instance_address,
    DAGSTER_POSTGRES_DB       = module.postgres.db_instance_name
  }
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = module.postgres.db_instance_master_user_secret_arn
}

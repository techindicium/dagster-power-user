terraform {
  backend "s3" {
    key = "infra/cluster/terraform.tfstate"
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
  account_id    = data.aws_caller_identity.current.account_id
  postgres_auth = tomap(jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string))
  dagster_env = {
    DAGSTER_POSTGRES_USER     = local.postgres_auth["username"],
    DAGSTER_POSTGRES_PASSWORD = local.postgres_auth["password"],
    DAGSTER_POSTGRES_HOSTNAME = data.aws_db_instance.postgres.address,
    DAGSTER_POSTGRES_DB       = data.aws_db_instance.postgres.db_name
  }
}


data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "dagster" {
  registry_id = local.account_id
}

data "aws_vpc" "dagster" {
  tags = {
    Project = local.project_name
  }

}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dagster.id]
  }

  tags = {
    Tier = "Public"
  }
}

data "aws_db_instance" "postgres" {
  db_instance_identifier = "${local.project_name}-db"
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = data.aws_db_instance.postgres.master_user_secret.0.secret_arn
}

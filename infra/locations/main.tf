terraform {
  backend "s3" {
    key = "infra/locations/terraform.tfstate"
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
  project_name = "dagster-ecs-poc"
  cluster_name = "${local.project_name}-cluster"
  private_subnets_cidr_blocks = [
    for id in data.aws_subnets.private.ids : data.aws_subnet.private[id].cidr_block
  ]
  dagster_env_vars = toset(
    [
      "DAGSTER_POSTGRES_USER",
      "DAGSTER_POSTGRES_PASSWORD",
      "DAGSTER_POSTGRES_HOSTNAME",
      "DAGSTER_POSTGRES_DB"
    ]
  )
}


data "aws_secretsmanager_secret" "postgres" {
  for_each = local.dagster_env_vars
  name     = each.value
}

data "aws_ecs_cluster" "dagster" {
  cluster_name = "${local.project_name}-cluster"
}

data "aws_vpc" "dagster" {
  tags = {
    Project = local.project_name
  }

}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dagster.id]
  }

  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_iam_role" "task_exec" {
  name = "${local.project_name}-task-exec-role"
}

data "aws_security_group" "postgres" {
  vpc_id = data.aws_vpc.dagster.id
  name   = "${local.project_name}-postgres-sg"
}

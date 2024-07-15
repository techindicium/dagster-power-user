terraform {
  backend "s3" {
    key = "infra/dagster/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.36.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
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

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.dagster.proxy_endpoint
    username = data.aws_ecr_authorization_token.dagster.user_name
    password = data.aws_ecr_authorization_token.dagster.password
  }
}

locals {
  project_name = "dagster-ecs-poc"
  cluster_name = "${local.project_name}-cluster"
  account_id   = data.aws_caller_identity.current.account_id
  private_subnets_cidr_blocks = [
    for id in data.aws_subnets.private.ids : data.aws_subnet.private[id].cidr_block
  ]
  base_dagster_tasks_role_statements = [
    {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = ["*"]
      condition = {
        test     = "StringLike"
        variable = "iam:PassedToService"
        values   = ["ecs.tasks.amazonaws.com"]
      }
    },
    {
      effect    = "Allow"
      actions   = ["s3:ListBucket"]
      resources = [data.aws_s3_bucket.dagster.arn]
    },
    {
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject"]
      resources = ["${data.aws_s3_bucket.dagster.arn}/dagster_compute/*"]
    },
  ]
  specific_dagster_task_role_statement = {
    webserver = {
      effect = "Allow"
      actions = [
        "ecs:DescribeTasks",
        "ecs:StopTask"
      ]
      resources = ["*"]
    }

    daemon = {
      effect = "Allow"
      actions = [
        "ec2:DescribeNetworkInterfaces",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListAccountSettings",
        "ecs:RegisterTaskDefinition",
        "ecs:RunTask",
        "ecs:TagResource",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecrets",
        "secretsmanager:GetSecretValue"
      ],
      resources = ["*"]
    }
  }
  dagster_env_vars = toset(
    [
      "DAGSTER_POSTGRES_USER",
      "DAGSTER_POSTGRES_PASSWORD",
      "DAGSTER_POSTGRES_DB",
      "DAGSTER_POSTGRES_HOSTNAME"
    ]
  )
}

data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "dagster" {
  registry_id = local.account_id
}

data "aws_secretsmanager_secret" "postgres" {
  for_each = local.dagster_env_vars
  name     = each.value
}

data "aws_secretsmanager_secret" "ecr" {
  name = "ecr-auth"
}

data "aws_lb_target_group" "dagster" {
  name = "dagster"
}
data "aws_lb" "dagster" {
  name = "${local.project_name}-alb"
}

data "aws_iam_role" "task_exec" {
  name = "${local.project_name}-task-exec-role"
}

data "aws_ecs_cluster" "dagster" {
  cluster_name = local.cluster_name
}

data "aws_vpc" "dagster" {
  tags = {
    Project = local.project_name
  }

}

data "aws_security_group" "alb" {
  vpc_id = data.aws_vpc.dagster.id
  name   = "${local.project_name}-alb-sg"
}

data "aws_security_group" "postgres" {
  vpc_id = data.aws_vpc.dagster.id
  name   = "${local.project_name}-postgres-sg"
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

data "aws_s3_bucket" "dagster" {
  bucket = "${local.project_name}-logs-bucket"
}

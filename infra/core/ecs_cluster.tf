module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = local.cluster_name

  create_task_exec_iam_role          = true
  task_exec_iam_role_name            = "${local.project_name}-task-exec-role"
  task_exec_iam_role_use_name_prefix = false
  task_exec_secret_arns = concat(
    [
      module.ecr_secret.secret_arn
    ],
    [
      for var, _ in local.dagster_env :
      module.postgres_secrets[var].secret_arn
    ]
  )
  task_exec_iam_statements = [
    {
      sid       = "EnableCreatingLogGroups"
      actions   = ["logs:CreateLogGroup"]
      effect    = "Allow"
      resources = ["*"]
    }
  ]

  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.dagster.arn
  }

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.project_name}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

resource "aws_service_discovery_http_namespace" "dagster" {
  name        = "dagster"
  description = "Service connect namespace for dagster deployments."
}

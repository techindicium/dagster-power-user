module "postgres_secrets" {
  source   = "terraform-aws-modules/secrets-manager/aws"
  for_each = local.dagster_env

  # Secret
  name                    = each.key
  description             = "${split("_", each.key)[2]} env var for auth in Dagster Postgres."
  recovery_window_in_days = 0

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = [module.ecs_cluster.task_exec_iam_role_arn]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password = false
  secret_string          = each.value

  tags = {
    "dagster-env" = "dagster"
  }

}

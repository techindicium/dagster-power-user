module "el_secrets" {
  source   = "terraform-aws-modules/secrets-manager/aws"
  for_each = var.el_env

  # Secret
  name                    = each.key
  description             = "Secret for ${each.key} el env var."
  recovery_window_in_days = 0

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = [data.aws_iam_role.task_exec.arn]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password = false
  secret_string          = each.value

  tags = {
    "dagster-env" = "el"
  }
}

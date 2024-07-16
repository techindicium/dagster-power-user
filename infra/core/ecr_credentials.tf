
module "ecr_secret" {
  source = "terraform-aws-modules/secrets-manager/aws"

  # Secret
  name                    = "ecr-auth"
  description             = "ECR auth secret for use in ECS secret"
  recovery_window_in_days = 0

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid    = "AllowAccountRead"
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
  secret_string = jsonencode({
    username = data.aws_ecr_authorization_token.dagster.user_name,
    password = data.aws_ecr_authorization_token.dagster.password
  })

}

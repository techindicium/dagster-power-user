module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  for_each = var.image_tags

  repository_name = "${local.project_name}-${each.key}"

  repository_image_scan_on_push   = false
  repository_force_delete         = true

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
